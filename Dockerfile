FROM php:8.2-apache

# 1. Instalar dependencias
RUN apt-get update && apt-get install -y unzip git libmariadb-dev curl libpng-dev libonig-dev libxml2-dev && rm -rf /var/lib/apt/lists/*
RUN docker-php-ext-install pdo pdo_mysql bcmath gd
RUN curl -sL https://deb.nodesource.com/setup_20.x | bash - && apt-get install -y nodejs

# 2. EL PARCHE MAESTRO: Desactiva el módulo 'event' y activa 'prefork'
# Esto mata el error de "More than one MPM loaded" de tus fotos
RUN a2dismod mpm_event || true && a2enmod mpm_prefork && a2enmod rewrite

# 3. Configurar Apache para /public
ENV APACHE_DOCUMENT_ROOT /var/www/html/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

# 4. Copiar código y Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer
WORKDIR /var/www/html
COPY . .

# 5. Build del proyecto
RUN composer install --no-interaction --optimize-autoloader --no-dev
RUN npm install && npm run build
RUN php artisan optimize && php artisan storage:link
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache

EXPOSE 80
# 6. Arrancar (Como las tablas ya se crearon, esto solo encenderá la web)
CMD php artisan migrate --force && apache2-foreground
