# Fase 1: Construir los assets con Node.js
FROM node:20 as build-assets

WORKDIR /var/www/html

# Copia package.json y package-lock.json
COPY package.json package-lock.json vite.config.js ./

# Instala dependencias
RUN npm install

# Copia el resto del código
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

# Activamos mod_rewrite y otros módulos
RUN a2enmod rewrite headers expires mime setenvif

# Instalamos extensiones PHP
RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath opcache

# Instalar Imagick
RUN pecl install imagick && docker-php-ext-enable imagick

# Instalar Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Directorio de trabajo
WORKDIR /var/www/html

# Copiamos solo los archivos necesarios
COPY . .

# Copiamos los assets construidos
COPY --from=build-assets /var/www/html/public/build public/build
COPY --from=build-assets /var/www/html/public/build/manifest.json public/build/manifest.json

# Configuración de Apache
COPY .docker/apache/000-default.conf /etc/apache2/sites-available/000-default.conf

# Permisos
RUN chown -R www-data:www-data /var/www/html && \
    chmod -R 755 /var/www/html

# Directorios de storage
RUN mkdir -p /var/www/html/storage/app/public && \
    chown -R www-data:www-data /var/www/html/storage && \
    chmod -R 755 /var/www/html/storage

# Instalar dependencias PHP
RUN composer install --optimize-autoloader --no-dev --no-scripts

# Generar clave y enlazar storage
RUN php artisan key:generate --force
RUN php artisan storage:link

# Caché (opcional en producción)
# RUN php artisan config:cache
# RUN php artisan route:cache
# RUN php artisan view:cache

# Script de inicio
COPY start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 80

CMD ["/start.sh"]