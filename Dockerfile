FROM php:8.2-cli

# Dependencias del sistema
RUN apt-get update && apt-get install -y \
    unzip git curl libpng-dev libonig-dev libxml2-dev libmariadb-dev nodejs npm \
    && rm -rf /var/lib/apt/lists/*

# Extensiones PHP
RUN docker-php-ext-install pdo pdo_mysql bcmath gd

# Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Carpeta app
WORKDIR /var/www/html
COPY . .

# Instalar Laravel
RUN composer install --no-dev --optimize-autoloader

# Frontend (Inertia + Vite)
RUN npm install && npm run build

# Permisos
RUN chmod -R 775 storage bootstrap/cache

# Optimización Laravel
RUN php artisan optimize && php artisan storage:link

# Puerto Railway
EXPOSE 8080

# Servidor Laravel (sin Apache 🔥)
CMD php artisan migrate --force && php artisan serve --host=0.0.0.0 --port=8080
