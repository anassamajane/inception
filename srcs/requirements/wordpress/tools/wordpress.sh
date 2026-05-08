#!/bin/bash

echo "Waiting for MariaDB..."
until mysql -h"$MYSQL_HOST" -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" -e "SELECT VERSION();" > /dev/null; do
    sleep 1
done

echo "MariaDB is fully ready!"

cd /var/www/html

# create config if not exists
if [ ! -f wp-config.php ]; then
	echo "Creating wp-config.php..."

	wp config create \
		--dbname="$MYSQL_DATABASE" \
		--dbuser="$MYSQL_USER" \
		--dbpass="$MYSQL_PASSWORD" \
		--dbhost="$MYSQL_HOST" \
		--allow-root
fi

# install wordpress if not installed
if ! wp core is-installed --allow-root;then
	wp core install \
		--url="$WP_URL" \
		--title="$WP_TITLE" \
		--admin_user="$WP_ADMIN_USER" \
		--admin_password="$WP_ADMIN_PASSWORD" \
		--admin_email="$WP_ADMIN_EMAIL" \
		--allow-root
fi

# install redis plugin
wp plugin install redis-cache --activate --allow-root

# configure redis in wp-config.php
wp config set WP_REDIS_HOST "redis" --allow-root
wp config set WP_REDIS_PORT 6379 --raw --allow-root

# enable cache
wp redis enable --allow-root

# create second user if not exists
if ! wp user get "$WP_USER" --allow-root > /dev/null 2>&1; then
	echo "Ceating second user..."

	wp user create "$WP_USER" "$WP_USER_EMAIL" \
		--user_pass="$WP_USER_PASSWORD" \
		--role=author \
		--allow-root
fi

echo "Starting PHP-FPM..."

exec php-fpm8.2 -F
