FROM php:8.2-apache

# 1. Instalar dependencias del sistema
RUN apt-get update && apt-get install -y \
    unzip \
    git \
    libmariadb-dev \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    && rm -rf /var/lib/apt/lists/*

# 2. Instalar extensiones de PHP
RUN docker-php-ext-install pdo pdo_mysql bcmath gd

# 3. Instalar Node.js y NPM correctamente
RUN curl -sL https://deb.nodesource.com/setup_22.x | bash - \
    && apt-get install -y nodejs

# 4. Habilitar mod_rewrite y corregir error de MPM (Multi-Processing Module)
# Esto evita el error AH00534 al desactivar mpm_event y activar mpm_prefork
RUN a2dismod mpm_event && a2enmod mpm_prefork && a2enmod rewrite

# 5. Configurar Apache para que apunte a /public
ENV APACHE_DOCUMENT_ROOT /var/www/html/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

# 6. Copiar Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# 7. Configurar directorio y copiar archivos
WORKDIR /var/www/html
COPY . .

# 8. Instalar dependencias de PHP y corregir permisos
# Se usa --no-dev para producción
RUN composer install --no-interaction --optimize-autoloader --no-dev
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache

# 9. Exponer puerto y arrancar Apache
EXPOSE 80
CMD ["apache2-foreground"]
