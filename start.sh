#!/bin/bash

set -e

echo "🔧 Ajustando permisos..."
chown -R www-data:www-data /var/www/html/storage/app/public/
chmod -R 755 /var/www/html/storage/app/public/

echo "🚀 Iniciando Apache..."
exec apache2-foreground