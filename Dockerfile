FROM php:5.6.6-apache

WORKDIR /var/www/html

# Install required packages and PHP modules
RUN apt-get update \
    && apt-get -y install \
            git \
            libmcrypt-dev \
            zlib1g-dev \
        --no-install-recommends \
    && rm -r /var/lib/apt/lists/* \

    # Install PHP extensions
    && docker-php-ext-install pdo_mysql \
    && docker-php-ext-install mbstring \
    && docker-php-ext-install mcrypt \
    && docker-php-ext-install zip \
    && pecl install apcu-beta && echo extension=apcu.so > /usr/local/etc/php/conf.d/apcu.ini \

    # Install composer
    && curl -sS https://getcomposer.org/installer | php \
    && mv composer.phar /usr/local/bin/composer \

    && composer global require "fxp/composer-asset-plugin:1.0.0" \

    && a2enmod rewrite \

    # Update apache2.conf
    && sed -i 's#DocumentRoot /var/www/html#DocumentRoot /var/www/html/web#' /etc/apache2/apache2.conf \

    # Fix write permissions with shared folders
    && usermod -u 1000 www-data

# Composer packages are installed outside the app directory /var/www/html.
# This way developers can mount the source code from their host directory
# into /var/www/html and won't end up with an empty vendors/ directory.
COPY composer.json /var/www/html/
COPY composer.lock /var/www/html/
RUN composer self-update --no-progress && \
    composer install --no-progress
