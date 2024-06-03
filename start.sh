#!/bin/sh

# UPDATE THE WEBROOT IF REQUIRED.
if [[ ! -z "${WEBROOT}" ]] && [[ ! -z "${WEBROOT_PUBLIC}" ]]; then
    sed -i "s#root /var/www/public;#root ${WEBROOT_PUBLIC};#g" /etc/nginx/sites-available/default.conf
else
    export WEBROOT=/var/www
    export WEBROOT_PUBLIC=/var/www/public
fi

# LARAVEL APPLICATION
if [[ "${LARAVEL_APP}" == "1" ]]; then
    # INSTALL LARAVEL PACKAGES.
    if [[ "${INSTALL_LARAVEL_PACKAGES}" == "1" ]]; then
        cd ${WEBROOT}
        sudo composer install --no-interaction --prefer-dist --optimize-autoloader
    fi
    # RUN LARAVEL MIGRATIONS ON BUILD.
    if [[ "${RUN_LARAVEL_MIGRATIONS_ON_BUILD}" == "1" ]]; then
        cd ${WEBROOT}
        sudo php artisan migrate
        # run tenants migration
        if [[ "${RUN_TENANTS_MIGRATION}" == "1" ]]; then
            cd ${WEBROOT}
            sudo php artisan tenants:migrate
        fi
        # run admin archive migration
        if [[ "${RUN_ADMIN_ARCHIVE_MIGRATION}" == "1" ]]; then
            cd ${WEBROOT}
            sudo php artisan migrate --path=database/migrations/archived_migrations
        fi
        # clear opcache
        cd ${WEBROOT}
        sudo php -r "opcache_reset();"
        # # restart pulse
        # cd ${WEBROOT}
        # php artisan pulse:restart
    fi

    if [[ "${RUN_PASSPORT_INSTALL_KEYS}" == "1" ]]; then
        cd ${WEBROOT}
        sudo php artisan passport:keys
    fi

    # LARAVEL SCHEDULER
    if [[ "${RUN_LARAVEL_SCHEDULER}" == "1" ]]; then
        sudo echo '* * * * * cd /var/www && sudo php artisan schedule:run >> /dev/null 2>&1' | sudo tee /etc/crontabs/kubernetesuser > /dev/null
        sudo crond
    fi
fi

# laravel storage folder permissions
sudo chmod -R 777 ${WEBROOT}/storage
sudo chmod -R 777 ${WEBROOT}/bootstrap/cache
sudo chmod -R 777 ${WEBROOT}/storage/logs

# SYMLINK CONFIGURATION FILES.
sudo ln -s /etc/php8.3/php.ini /etc/php/8.3/fpm/php.ini
sudo ln -s /etc/nginx/sites-available/default.conf /etc/nginx/sites-enabled/default.conf

# PHP & SERVER CONFIGURATIONS.
if [[ ! -z "${PHP_MEMORY_LIMIT}" ]]; then
    sed -i "s/memory_limit = 128M/memory_limit = ${PHP_MEMORY_LIMIT}M/g" /etc/php/8.3/fpm/php.ini
fi

if [ ! -z "${PHP_POST_MAX_SIZE}" ]; then
    sed -i "s/post_max_size = 50M/post_max_size = ${PHP_POST_MAX_SIZE}M/g" /etc/php/8.3/conf.d/php.ini
fi

if [ ! -z "${PHP_UPLOAD_MAX_FILESIZE}" ]; then
    sed -i "s/upload_max_filesize = 10M/upload_max_filesize = ${PHP_UPLOAD_MAX_FILESIZE}M/g" /etc/php/8.3/conf.d/php.ini
fi

# START SUPERVISOR.
exec sudo /usr/bin/supervisord -n -c /etc/supervisord.conf
