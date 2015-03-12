Yii 2 Base
==========

This is a base image for Yii 2 projects.

> **IMPORTANT: The image does *not* contain an app template!**

The main purpose of this image is,

 * to provide a PHP runtime environment that is configured for Yii and
 * that has the base yii2 composer packages pre-installed.

## 1. How to use this Image

To make use of this image you have to combine it with your application source
code and probably extend from it in your own `Dockerfile`. For now you can either

 * create an app based on our [yii2-dockerized](https://github.com/codemix/yii2-dockerized) template or
 * build your app manually.


### 1.1 Using yii2-dockerized

We provide a Yii2 application template that is based on this image, which you
can use as starting point for your own development. For more details check out the
docs for [yii2-dockerized](https://github.com/codemix/yii2-dockerized).


### 1.2 Building An App Manually

To use this image in your custom setup, you have to understand the basic
idea behind it:

 * The image has all yii2 related composer packages pre-installed
   under `/var/www/vendor`.
 * The application code is expected under `/var/www/html`, with
   the public directory being `/var/www/html/web`.
 * You will *never* install any composer packages locally, but
   always into your container. If you do so, this will either override
   or add more packages to those already contained in this image.

### 1.2.1 Basic setup

So to get started you can create your own application template. You could
start with the official base image (requires `composer` to be installed
locally):

```
composer create-project --no-install yiisoft/yii2-base-app
```

> **Note:** Make sure you set the correct path for the composer autoloader
> (`/var/www/vendor/autoload.php`). You should also configure the `vendorPath`
> application setting in your configuration.

If you don't need any extra composer packages besides the yii2 packages,
you can start with a very simple `Dockerfile`:

```
FROM codemix/yii2-base:2.0.3-php-5.6.6-apache

# Copy your app's source code into the container
COPY . /var/www/html
```

and a `docker-compose.yml`:

```
web:
    build: ./
    ports:
        - "8080:80"
    expose:
        - "80"
    volumes:
        - ./:/var/www/html/
```

### 1.2.2 Adding Composer Packages

To add composer packages, you need to provide a `composer.json` with
some modifications:


```
{
  "require": {
    "php": ">=5.4.0",
    "yiisoft/yii2": "2.0.3",
    "yiisoft/yii2-bootstrap": "2.0.3",
    "yiisoft/yii2-swiftmailer": "2.0.3"
  },
  "require-dev": {
    "yiisoft/yii2-debug": "2.0.3",
    "yiisoft/yii2-gii": "2.0.3"
  },
  "config": {
    "process-timeout": 1800,
    "vendor-dir": "/var/www/vendor"
  },
  "extra": {
    "asset-installer-paths": {
      "npm-asset-library": "../vendor/npm",
      "bower-asset-library": "../vendor/bower"
    }
  }
}
```

Note the `vendor-dir` configuration, which is crucial for this setup. It's also
important, that the versions there match those of this image. Otherwhise you again
loose the advantage of reusing the composer packages contained in the image.

You also have to map the local directory into the container in your `docker-compose.yml`.
If you have problems with githubs rate limit, you can provide a github API token.

```
web:
    build: ./
    ports:
        - "8080:80"
    expose:
        - "80"
    volumes:
        - ./:/var/www/html/
    environment:
        API_TOKEN: "<YOUR GITHUB API TOKEN>"
```

Now you can run the bundled `composer` command in your container.

```
docker-compose run --rm web compose update myrepo/mypackage
```

#### 1.2.3 Adding PHP Extensions

Since this image extends from the official [php](https://registry.hub.docker.com/u/library/php/)
image, you can use `docker-php-ext-install` in your Dockerfile. Here's an example:

```
RUN apt-get update \
    && apt-get -y install \
            libfreetype6-dev \
            libjpeg62-turbo-dev \
            libmcrypt-dev \
            libpng12-dev \
        --no-install-recommends \
    && rm -r /var/lib/apt/lists/* \
    && docker-php-ext-install iconv mcrypt \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install gd
```
