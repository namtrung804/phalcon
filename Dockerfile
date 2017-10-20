FROM php:7.1-fpm

LABEL maintainer "https://github.com/amq/"

ENV PHALCON_VERSION=3.2.2
ENV DEVTOOLS_VERSION=3.2.2

COPY conf/php/php.ini /usr/local/etc/php/

RUN set -xe \

# cphalcon
    && curl -LO https://github.com/phalcon/cphalcon/archive/v${PHALCON_VERSION}.tar.gz \
    && tar xzf v${PHALCON_VERSION}.tar.gz \
    && cd cphalcon-${PHALCON_VERSION}/build \
    && ./install \
    && echo "extension=phalcon.so" > /usr/local/etc/php/conf.d/phalcon.ini \
    && cd ../.. \
    && rm -rf v${PHALCON_VERSION}.tar.gz cphalcon-${PHALCON_VERSION} \

# devtools
    && curl -LO https://github.com/phalcon/phalcon-devtools/archive/v${DEVTOOLS_VERSION}.tar.gz \
    && tar xzf v${DEVTOOLS_VERSION}.tar.gz \
    && mv phalcon-devtools-${DEVTOOLS_VERSION} /usr/local/phalcon-devtools \
    && ln -s /usr/local/phalcon-devtools/phalcon.php /usr/local/bin/phalcon \
    && rm -f v${DEVTOOLS_VERSION}.tar.gz

# composer
ENV COMPOSER_VERSION=1.5.2
RUN curl -L https://getcomposer.org/installer -o composer-setup.php \
    && php composer-setup.php --version=${COMPOSER_VERSION} --install-dir=/usr/local/bin --filename=composer \
    && rm -f composer-setup.php

# php modules

RUN apt-get update -y \
    && apt-get install -y libfreetype6-dev libjpeg62-turbo-dev libpng12-dev libxml2-dev zlib1g-dev unzip git --no-install-recommends --no-install-suggests \
    && apt-get clean -y \
    && pecl install redis xdebug \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd \
    && docker-php-ext-enable redis xdebug \
    && docker-php-ext-install mbstring xml opcache pdo_mysql mysqli soap zip session bcmath ctype dom hash sockets pdo fileinfo gettext iconv xmlrpc xmlwriter

WORKDIR /app

RUN usermod -u 1000 www-data
