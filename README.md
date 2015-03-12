Yii 2 Base
==========

This is a base image for Yii 2 projects.

> **IMPORTANT: The image does *not* contain an app template!**

The main purpose of this image is,

 * to provide a PHP runtime environment that is configured for Yii and
 * that has the base yii2 composer packages pre-installed.

## How to use this Image

To make use of this image you will combine it with your application source
code and probably extend from it in your own `Dockerfile`. We also provide
an application template called [yii2-dockerized]() that you can use as
basis for your own application.

But you can also do a manual setup. We still recommend to study our example
template to see how things fit together.

### Using yii2-dockerized

This template serves as a basis for your own development. You *will*
modify it to suit your needs. For more details check out the
docs for [yii2-dockerized](https://github.com/codemix/yii2-dockerized).


### Manual setup

To use this image in your custom setup, you have to understand the basic
idea behind it:

 * The image has all yii2 related composer packages pre-installed
   under `/var/www/vendor`.
 * The application code is expected under `/var/www/html`, with
   the public directory being `/var/www/html/web`.
 * You will *never* install any composer packages locally, but
   always into your container. If you do so, this will either override
   or add more packages to those already contained in this image.

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

#### Adding PHP extensions

To add PHP extensions you can add a line like this to your `Dockerfile`:

```
RUN docker-php-ext-install <extension_name>
```
