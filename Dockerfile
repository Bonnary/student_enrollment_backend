FROM php:8.2-fpm

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libsqlite3-dev \
    zip \
    unzip \
    libssl-dev

# Install PHP extensions required for SMTP
RUN docker-php-ext-install pdo_sqlite && \
    docker-php-ext-install sockets && \
    pecl install openssl && \
    docker-php-ext-enable openssl

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Get Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /var/www/html

# Copy composer files first
COPY composer.json composer.lock ./

# Install dependencies
RUN composer install --no-scripts --no-autoloader --no-dev

# Copy rest of the application
COPY . .

# Generate optimized autoloader
RUN composer dump-autoload --optimize --no-dev

# Copy environment file
COPY .env.example .env

# Generate application key
RUN php artisan key:generate

# Set permissions
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html/storage

# Create and configure SQLite database
RUN touch database/database.sqlite \
    && chown -R www-data:www-data database/database.sqlite \
    && chmod 664 database/database.sqlite

# Run migrations
RUN php artisan migrate --force

EXPOSE 8000
EXPOSE 465

CMD php artisan serve --host=0.0.0.0 --port=8000
