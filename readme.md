# Web Server

Nginx & PHP 8.3 web server.

# Laravel Application - Quick Run

Using the Laravel installer you can get up and running with a Laravel application inside Docker in minutes.

- Create a new Laravel application `$ laravel new testapp`
- Change to the applications directory `$ cd testapp`
- Start the container and attach the application. `$ docker run -d -p 4488:80 --name=testapp -v $PWD:/var/www solutechlimited/nginx-php-server:latest`
- Visit the Docker container URL like [http://0.0.0.0:4488](http://0.0.0.0:4488). Profit!

### Args

Here are some args

- `NGINX_HTTP_PORT` - HTTP port. Default: `80`.
- `NGINX_HTTPS_PORT` - HTTPS port. Default: `443`.
- `PHP_VERSION` - The PHP version to install. Supports: `>8.2`. Default: `8.3`.
- `ALPINE_VERSION` - The Alpine version. Supports: `3.9`. Default: `3.9`.

### Environment Variables

Here are some configurable environment values.

- `WEBROOT` – Path to the web root. Default: `/var/www`
- `WEBROOT_PUBLIC` – Path to the web root. Default: `/var/www/public`
- `COMPOSER_DIRECTORY` - Path to the `composer.json` containing directory. Default: `/var/www`.
- `COMPOSER_INSTALL_ON_BUILD` - Should `composer install` run on build. Default: `0`.
- `LARAVEL_APP` - Is this a Laravel application. Default `0`.
- `RUN_LARAVEL_SCHEDULER` - Should the Laravel scheduler command run. Only works if `LARAVEL_APP` is `1`. Default: `0`.
- `RUN_LARAVEL_MIGRATIONS_ON_BUILD` - Should the migrate command run during build. Only works if `LARAVEL_APP` is `1`. Default: `0`.
- `PRODUCTION` – Is this a production environment. Default: `0`
- `PHP_MEMORY_LIMIT` - PHP memory limit. Default: `128M`
- `PHP_POST_MAX_SIZE` - Maximum POST size. Default: `50M`
- `PHP_UPLOAD_MAX_FILESIZE` - Maximum file upload file. Default: `10M`.
