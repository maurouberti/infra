FROM php:8.3-fpm-alpine
WORKDIR /var/www
RUN apk add --no-cache bash

# gd
RUN apk add --no-cache \
    zlib \
    libpng \
    libjpeg-turbo-dev \
    libwebp-dev \
    freetype-dev \
    libxpm-dev \
    libavif-dev \
    && docker-php-ext-configure gd --with-jpeg --with-webp --with-freetype --with-xpm --with-avif \
    && docker-php-ext-install gd

# MySql
RUN apk add --no-cache \
    mysql-client \
    && docker-php-ext-install pdo_mysql

# PostgreSQL
RUN apk add --no-cache \
    postgresql-client \
    postgresql-dev \
    && docker-php-ext-install pdo_pgsql

# Redis
RUN apk add --no-cache \
    gcc \
    g++ \
    make \
    autoconf \
    libc-dev \
    && pecl install redis-5.3.7 \
    && docker-php-ext-enable redis \
    && apk del gcc g++ make autoconf libc-dev \
    && rm -rf /var/cache/apk/*

# Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Git
RUN apk add --no-cache \
    git


RUN git clone --depth 1 https://github.com/maurouberti/php-testes
RUN cp /var/www/php-testes/.env.exemplo /var/www/php-testes/.env
RUN cd /var/www/php-testes && composer install --ignore-platform-reqs --no-interaction
RUN chmod -R 775 /var/www/php-testes/public && \
    chgrp -R www-data /var/www/php-testes/public


EXPOSE 9000

CMD ["php-fpm"]
