FROM php:8.2-apache

# 1. Dependencias del sistema (Incluye lo necesario para MySQL y GD)
RUN apt-get update && apt-get install -y \
    unzip git libmariadb-dev curl libpng-dev libonig-dev libxml2-dev \
    && rm -rf /var/lib/apt/lists/*

# 2. Extensiones de PHP fundamentales para Laravel
RUN docker-php-ext-install pdo pdo_mysql bcmath gd

# 3. Node.js (Versión 20 LTS para que compile tu Vite/Inertia sin errores)
RUN curl -sL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs

# 4. LA SOLUCIÓN AL ERROR: Fix de MPM y habilitar Rewrite
# Aquí quitamos el módulo que causaba el error de "More than one MPM loaded"
RUN a2dismod mpm_event && a2enmod mpm_prefork && a2enmod rewrite

# 5. Configurar Apache para que apunte a la carpeta /public de Laravel
ENV APACHE_DOCUMENT_ROOT /var/www/html/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

# 6. Traer Composer al contenedor
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# 7. Copiar tu proyecto al contenedor
WORKDIR /var/www/html
COPY . .

# 8. Instalar dependencias de PHP y arreglar permisos de storage
RUN composer install --no-interaction --optimize-autoloader --no-dev
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache

# 9. Comando final para arrancar el servidor
EXPOSE 80
CMD ["apache2-foreground"]
