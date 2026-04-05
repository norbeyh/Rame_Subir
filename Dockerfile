FROM php:8.2-apache

# 1. Limpieza radical de módulos ANTES de instalar nada
# Esto borra físicamente el archivo que causa el error "HP"
RUN rm -f /etc/apache2/mods-enabled/mpm_event.load && \
    rm -f /etc/apache2/mods-available/mpm_event.load

# 2. Instalar dependencias
RUN apt-get update && apt-get install -y unzip git libmariadb-dev curl libpng-dev libonig-dev libxml2-dev && rm -rf /var/lib/apt/lists/*
RUN docker-php-ext-install pdo pdo_mysql bcmath gd
RUN curl -sL https://deb.nodesource.com/setup_20.x | bash - && apt-get install -y nodejs

# 3. Forzar el modo correcto
RUN a2dismod mpm_event || true && a2enmod mpm_prefork && a2enmod rewrite

# 4. Configurar Apache
ENV APACHE_DOCUMENT_ROOT /var/www/html/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

# 5. Código y Build
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer
WORKDIR /var/www/html
COPY . .
RUN composer install --no-interaction --optimize-autoloader --no-dev
RUN npm install && npm run build
RUN php artisan optimize && php artisan storage:link
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache

EXPOSE 80
# Mando final: Migrar y encender
CMD php artisan migrate --force && apache2-foreground
