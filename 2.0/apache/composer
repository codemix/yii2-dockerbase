#!/bin/bash

if [ -n "$API_TOKEN" ]
then
    php /usr/local/bin/composer.phar config -g github-oauth.github.com $API_TOKEN
fi

exec php /usr/local/bin/composer.phar "$@"
