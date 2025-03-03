FROM php:8.3-fpm-alpine

RUN apk add --no-cache bash

# MySql
RUN apk add --no-cache \
    mysql-client \
    && docker-php-ext-install mysqli pdo_mysql

# Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Git
RUN apk add --no-cache git

# App
RUN mkdir -p /var/www/php-testes
WORKDIR /var/www/php-testes
COPY . .
RUN cp .env.exemplo .env
RUN composer install --ignore-platform-reqs --no-interaction
RUN chmod -R 775 public && \
    chgrp -R www-data public


EXPOSE 9000

CMD ["php-fpm"]
