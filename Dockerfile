# Alpine Image for Nginx and PHP

# NGINX x ALPINE.
FROM nginx:alpine

# MAINTAINER OF THE PACKAGE.
LABEL maintainer="Neo Ighodaro <neo@creativitykills.co>"

# trust this project public key to trust the packages.
ADD https://dl.bintray.com/php-alpine/key/php-alpine.rsa.pub /etc/apk/keys/php-alpine.rsa.pub

# CONFIGURE ALPINE REPOSITORIES AND PHP BUILD DIR.
FROM php:8.2-fpm-alpine

# INSTALL SYSTEM PACKAGES PHP AND SOME EXTENSIONS. SEE: https://github.com/codecasts/php-alpine
RUN apk add --no-cache --update \
    ca-certificates \
    bash \
    supervisor \
    nginx \
    nano \
    php \
    php-fpm \
    php-openssl \
    php-pdo_mysql \
    php-mbstring \
    php-zlib \
    php-json \
    php-xml \
    php-common

# CONFIGURE WEB SERVER.
RUN mkdir -p /var/www && \
    mkdir -p /run/php && \
    mkdir -p /run/nginx && \
    mkdir -p /var/log/supervisor && \
    mkdir -p /etc/nginx/sites-enabled && \
    mkdir -p /etc/nginx/sites-available

# INSTALL COMPOSER.
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# ADD START SCRIPT, SUPERVISOR CONFIG, NGINX CONFIG AND RUN SCRIPTS.
COPY config/supervisor/supervisord.conf /etc/supervisord.conf
COPY config/nginx/nginx.conf /etc/nginx/nginx.conf
COPY config/nginx/site.conf /etc/nginx/sites-available/default.conf
COPY config/php/php.ini /etc/php8.2/php.ini
COPY config/php-fpm/www.conf /etc/php/8.2/fpm/pool.d/www.conf

# make the shell script on the root directory executable
COPY start.sh /usr/local/bin/start.sh
RUN chmod +x /usr/local/bin/start.sh

# EXPOSE PORTS!
ARG NGINX_HTTP_PORT=80
ARG NGINX_HTTPS_PORT=443
EXPOSE ${NGINX_HTTPS_PORT} ${NGINX_HTTP_PORT}

# SET THE WORK DIRECTORY.
WORKDIR /var/www

#GRANT PRIVILEGIES TO www-data user:group to read in /var/www
RUN chown -R www-data:www-data /var/www

# Start script file
CMD ["/usr/local/bin/start.sh"]
