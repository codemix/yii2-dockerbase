FROM estebanmatias92/hhvm:3.8.1-fastcgi

MAINTAINER haertl.mike@gmail.com

ENV PATH $PATH:/root/.composer/vendor/bin

# Install composer and prepare system
RUN apt-get update \
    && apt-get -y install \
            curl \
            git \
            # We need PHP for composer because there's an issue with HHVM and yii2-composer which
            # breaks the creation of extensions.php (https://github.com/facebook/hhvm/issues/4797)
            php5-cli \
        --no-install-recommends \
    && rm -r /var/lib/apt/lists/* \

    && curl -sS https://getcomposer.org/installer | php \
    && mv composer.phar /usr/local/bin/composer.phar \

    && composer.phar global require --no-progress "fxp/composer-asset-plugin:~1.4.2" \
    && composer.phar global require --no-progress "codeception/codeception=2.0.*" \
    && composer.phar global require --no-progress "codeception/specify=*" \
    && composer.phar global require --no-progress "codeception/verify=*" \

    # Fix write permissions with shared folders
    && usermod -u 1000 www-data

COPY composer /usr/local/bin/

WORKDIR /var/www/html

# Composer packages are installed outside the app directory /var/www/html.
# This way developers can mount the source code from their host directory
# into /var/www/html and won't end up with an empty vendors/ directory.
COPY composer.json /var/www/html/
COPY composer.lock /var/www/html/
RUN composer install --prefer-dist --no-progress \
    && rm composer.*
