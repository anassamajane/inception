#!/bin/bash

set -e
set -x

echo "Waiting for MariaDB..."
MAX_TRIES=30
COUNT=0
until mysql -h"$MYSQL_HOST" -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" -e "SELECT 1;" "$MYSQL_DATABASE" 2>&1; do
    COUNT=$((COUNT+1))
    if [ $COUNT -ge $MAX_TRIES ]; then
        echo "MariaDB never became ready, giving up"
        exit 1
    fi
    echo "Attempt $COUNT/$MAX_TRIES - retrying in 3s..."
    sleep 3
done

echo "MariaDB is fully ready!"

cd /var/www/html/wordpress

if [ ! -f wp-config.php ]; then
    cp wp-config-sample.php wp-config.php

    sed -i "s/database_name_here/$MYSQL_DATABASE/" wp-config.php
    sed -i "s/username_here/$MYSQL_USER/" wp-config.php
    sed -i "s/password_here/$MYSQL_PASSWORD/" wp-config.php
    sed -i "s/localhost/$MYSQL_HOST/" wp-config.php
fi

echo "Starting PHP-FPM..."

exec php-fpm8.2 -F
