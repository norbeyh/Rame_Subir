FROM php:8.2-apache

# 1. Limpiar cualquier configuración previa de MPM que Railway intente forzar
RUN a2dismod mpm_event || true && a2enmod mpm_prefork && a2enmod rewrite

# 2. Dependencias del sistema
RUN apt-get update && apt-get install -y \
    unzip git libmariadb-dev curl libpng-dev libonig-dev libxml2-dev \
    && rm -rf /var/lib/apt/lists/*

# 3. Extensiones PHP
RUN docker-php-ext-install pdo pdo_mysql bcmath gd

# 4. Node.js 20 (Para Vite)
RUN curl -sL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs

# 5. Configurar Apache para /public
ENV APACHE_DOCUMENT_ROOT /var/www/html/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

# 6. Composer y Archivos
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer
WORKDIR /var/www/html
COPY . .

# 7. Construcción total (Lo que antes hacía la variable, ahora lo hace el Dockerfile)
RUN composer install --no-interaction --optimize-autoloader --no-dev
RUN npm install && npm run build
RUN php artisan optimize && php artisan storage:link
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache

EXPOSE 80
CMD ["apache2-foreground"]
