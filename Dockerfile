FROM php:8.2-apache

# 1. Instalar dependencias
RUN apt-get update && apt-get install -y unzip git libmariadb-dev curl libpng-dev libonig-dev libxml2-dev && rm -rf /var/lib/apt/lists/*

# 2. PHP Extensions
RUN docker-php-ext-install pdo pdo_mysql bcmath gd

# 3. Node.js
RUN curl -sL https://deb.nodesource.com/setup_20.x | bash - && apt-get install -y nodejs

# 4. FIX MPM (Borra el conflicto de raíz)
RUN rm -f /etc/apache2/mods-enabled/mpm_event.load && \
    a2enmod mpm_prefork && \
    a2enmod rewrite

# 5. Configurar Apache
ENV APACHE_DOCUMENT_ROOT /var/www/html/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

# 6. Copiar archivos
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer
WORKDIR /var/www/html
COPY . .

# 7. Instalación y Build
RUN composer install --no-interaction --optimize-autoloader --no-dev
RUN npm install && npm run build
RUN php artisan optimize && php artisan storage:link
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache

# 8. EL MANDO FINAL: Migrar y encender
EXPOSE 80
# Este comando intenta crear las tablas y luego arranca el servidor
CMD php artisan migrate --force && apache2-foreground
