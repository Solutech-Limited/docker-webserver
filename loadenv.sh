#!/bin/bash

if [[ "${LOAD_ENV}" == "1" ]]; then
    cp .env.example .env
    # replace environment variables
    # db variables
    sed -i "s/DB_DATABASE=/DB_DATABASE=$DB_DATABASE/g" .env
    sed -i "s/DB_USERNAME=/DB_USERNAME=$DB_USERNAME/g" .env
    sed -i "s/DB_PASSWORD=/DB_PASSWORD=$DB_PASSWORD/g" .env
fi

# execute
exec "$@"