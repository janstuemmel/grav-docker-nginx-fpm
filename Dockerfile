FROM php:7.2-fpm-alpine

ENV GRAV_VERSION 1.6.11

RUN addgroup app && adduser -S -u 1000 -s /bin/bash app -G app

RUN apk add --no-cache $PHPIZE_DEPS bash vim nginx git curl yaml yaml-dev zip htop libcap libzip-dev \
    freetype-dev libjpeg-turbo-dev libmcrypt-dev libpng-dev \
    php7-fpm php7-json php7-zlib php7-xml php7-pdo php7-phar php7-openssl \
    php7-gd php7-iconv php7-mcrypt php7-session php7-zip \
    php7-curl php7-opcache php7-ctype php7-apcu \
    php7-intl php7-bcmath php7-dom php7-mbstring php7-simplexml php7-xmlreader

RUN setcap 'cap_net_bind_service=+ep' /usr/sbin/nginx

RUN pecl install yaml zip apcu && \
    docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ && \
    docker-php-ext-install gd && \
    docker-php-ext-enable yaml zip gd apcu 

RUN mkdir -p /app && chown app -R /app

RUN mkdir -p /tmp/nginx && \
    mkdir -p /usr/logs/nginx && \
    chown app -R /tmp/nginx && \
    chown app -R /var/tmp/nginx && \
    touch /var/lib/nginx/logs/error.log && \
    chown app /var/lib/nginx/logs/error.log && \
    chown app -R /var/lib/nginx

ADD nginx /etc/nginx
ADD php/php-fpm.conf /etc/php7/
ADD php/php.ini /usr/local/etc/php/conf.d/settings.ini
ADD run.sh /app/run.sh

RUN chmod +x /app/run.sh

WORKDIR /app

USER app

RUN curl -o grav-tmp.zip -SL https://getgrav.org/download/core/grav-admin/${GRAV_VERSION} && \
    unzip grav-tmp.zip && mv grav-admin grav && rm grav-tmp.zip

EXPOSE 80

CMD ["/app/run.sh"]