FROM php:5.6.10-apache

MAINTAINER haertl.mike@gmail.com

ENV PATH $PATH:/root/.composer/vendor/bin

# Composer packages are installed outside the app directory /var/www/html.
# This way developers can mount the source code from their host directory
# into /var/www/html and won't end up with an empty vendors/ directory.
COPY composer.json /var/www/html/
COPY composer.lock /var/www/html/
