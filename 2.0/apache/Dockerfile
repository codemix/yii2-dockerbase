FROM php:5.6.6-apache

MAINTAINER haertl.mike@gmail.com

# Install composer and prepare system
RUN apt-get update \
    && apt-get -y install \
            git \
        --no-install-recommends \
    && rm -r /var/lib/apt/lists/* \

    && curl -sS https://getcomposer.org/installer | php \
    && mv composer.phar /usr/local/bin/composer.phar \

    && composer.phar global require --no-progress "fxp/composer-asset-plugin:1.0.0" \

    # Fix write permissions with shared folders
    && usermod -u 1000 www-data

# Install required PHP extensions
RUN apt-get update \
    && apt-get -y install \
            libmcrypt-dev \
            zlib1g-dev \
        --no-install-recommends \
    && rm -r /var/lib/apt/lists/* \

    # Enable mod_rewrite
    && a2enmod rewrite \

    # Install PHP extensions
    && docker-php-ext-install pdo_mysql \
    && docker-php-ext-install mbstring \
    && docker-php-ext-install mcrypt \
    && docker-php-ext-install zip \
    && pecl install apcu-beta && echo extension=apcu.so > /usr/local/etc/php/conf.d/apcu.ini

COPY composer /usr/local/bin/composer
COPY apache2.conf /etc/apache2/apache2.conf

WORKDIR /var/www/html

# Composer packages are installed outside the app directory /var/www/html.
# This way developers can mount the source code from their host directory
# into /var/www/html and won't end up with an empty vendors/ directory.
COPY composer.json /var/www/html/
COPY composer.lock /var/www/html/
RUN composer self-update --no-progress \
    && composer install --prefer-dist --no-progress \
    && rm composer.*
