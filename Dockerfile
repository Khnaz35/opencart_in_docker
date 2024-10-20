FROM php:8.2-fpm

RUN apt-get update && apt-get install -y \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip \
    curl \
    && docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd zip

RUN apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /var/www/html/opencart

COPY ./src /var/www/html/opencart

RUN chown -R www-data:www-data /var/www/html/opencart

EXPOSE 9000

CMD ["php-fpm"]
