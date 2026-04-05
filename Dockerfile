FROM php:8.2-cli
RUN echo "ESTE ES EL NUEVO DOCKER 🔥"
RUN apt-get update && apt-get install -y \
    unzip git curl libpng-dev libonig-dev libxml2-dev libmariadb-dev nodejs npm \
    && rm -rf /var/lib/apt/lists/*

RUN docker-php-ext-install pdo pdo_mysql bcmath gd

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html
COPY . .

RUN composer install --no-dev --optimize-autoloader
RUN npm install && npm run build

RUN chmod -R 775 storage bootstrap/cache
RUN php artisan optimize && php artisan storage:link
RUN php artisan config:clear && php artisan cache:clear
EXPOSE 8080

CMD php artisan migrate --force && php artisan serve --host=0.0.0.0 --port=8080
