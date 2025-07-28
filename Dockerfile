# Fase 1: Construir los assets con Node.js
FROM node:20 as build-assets

WORKDIR /var/www/html

COPY package.json package-lock.json vite.config.js ./
RUN npm install

COPY . .

# Ejecutamos el build de Vite
RUN npm run build


# Fase 2: Entorno PHP con Apache
FROM php:8.2-apache

LABEL maintainer="tu@correo.com"

# Instalamos dependencias del sistema
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    curl \
    libmagickwand-dev \
    && rm -rf /var/lib/apt/lists/*

# Activamos mod_rewrite y encabezados
RUN a2enmod rewrite headers expires mime

# Si usas proxy inverso o quieres soporte completo de X-Forwarded-Proto
RUN a2enmod setenvif

# Instalamos extensiones PHP necesarias para Laravel
RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath opcache

# Instalar extensión imagick
RUN pecl install imagick && docker-php-ext-enable imagick

# Instalamos Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Configuración del directorio de trabajo
WORKDIR /var/www/html

# Copiamos archivos del proyecto
COPY . .

# Copiamos solo los archivos compilados desde la fase de build
COPY --from=build-assets /var/www/html/public/build public/build
COPY --from=build-assets /var/www/html/public/build/manifest.json public/build/manifest.json

COPY .docker/apache/000-default.conf /etc/apache2/sites-available/000-default.conf

# Asegúrate de que el directorio public esté presente
RUN mkdir -p /var/www/html/public

RUN chown -R www-data:www-data /var/www/html && \
    chmod -R 755 /var/www/html

RUN mkdir -p /var/www/html/storage/app/public \
    && chown -R www-data:www-data /var/www/html/storage \
    && chmod -R 755 /var/www/html/storage

# Instalamos dependencias de PHP
RUN composer install

# Ahora generamos la APP_KEY solo si no existe
# RUN cp .env.production .env && php artisan key:generate --force

RUN php artisan storage:link 

# Caché de configuración
# RUN php artisan view:cache \
#     && php artisan event:cache \
#     && php artisan optimize

COPY start.sh /start.sh
RUN chmod +x /start.sh

# Exponemos puerto 80
EXPOSE 80

# Comando final para arrancar Apache
CMD ["/start.sh"]