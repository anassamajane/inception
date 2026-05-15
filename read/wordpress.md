# WordPress Service Explanation

## What is WordPress?

WordPress is a PHP-based CMS (Content Management System).

In this project, WordPress:

* runs PHP-FPM to process PHP files
* connects to MariaDB for all content storage
* connects to Redis for object caching
* serves files through Nginx via FastCGI on port 9000

---

## Dockerfile Explained

### Install PHP and dependencies

```dockerfile
RUN apt-get update && apt-get install -y \
    php \
    php-fpm \
    php-mysql \
    curl \
    mariadb-client
```

| Package | Purpose |
|---------|---------|
| `php` | PHP interpreter |
| `php-fpm` | FastCGI Process Manager — handles PHP requests from nginx |
| `php-mysql` | PHP extension to connect to MariaDB |
| `curl` | Download WordPress and WP-CLI |
| `mariadb-client` | MySQL client — used in the wait loop to check MariaDB is ready |

---

### Install WP-CLI

```dockerfile
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp
```

WP-CLI is a command line tool for WordPress. Used to:
* create wp-config.php
* install WordPress
* install plugins
* create users
* manage cache

---

### Download WordPress

```dockerfile
RUN curl -O https://wordpress.org/latest.tar.gz \
    && tar -xvf latest.tar.gz \
    && mv wordpress/* /var/www/html \
    && rm -rf wordpress latest.tar.gz
```

Downloads and extracts WordPress files directly into `/var/www/html`.

---

### Configure PHP-FPM to listen on port 9000

```dockerfile
RUN sed -i 's|listen = /run/php/php8.2-fpm.sock|listen = 9000|' /etc/php/8.2/fpm/pool.d/www.conf
```

By default PHP-FPM uses a Unix socket. This changes it to TCP port 9000 so nginx can reach it from another container.

---

## wordpress.sh Script Explained

### Wait for MariaDB

```bash
until mysql -h"$MYSQL_HOST" -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" -e "SELECT VERSION();" > /dev/null; do
    sleep 1
done
```

Waits until the actual user can authenticate — not just until the port is open. Prevents race conditions.

---

### Create wp-config.php

```bash
if [ ! -f wp-config.php ]; then
    wp config create \
        --dbname="$MYSQL_DATABASE" \
        --dbuser="$MYSQL_USER" \
        --dbpass="$MYSQL_PASSWORD" \
        --dbhost="$MYSQL_HOST" \
        --allow-root
fi
```

Creates the WordPress configuration file only if it doesn't already exist (second run protection).

---

### Install WordPress

```bash
if ! wp core is-installed --allow-root; then
    wp core install \
        --url="$WP_URL" \
        --title="$WP_TITLE" \
        --admin_user="$WP_ADMIN_USER" \
        --admin_password="$WP_ADMIN_PASSWORD" \
        --admin_email="$WP_ADMIN_EMAIL" \
        --allow-root
fi
```

Installs WordPress database tables and creates the admin user. Skipped if already installed.

---

### Install Redis cache plugin

```bash
if ! wp plugin is-installed redis-cache --allow-root; then
    wp plugin install redis-cache --activate --allow-root
    wp config set WP_REDIS_HOST "redis" --allow-root
    wp config set WP_REDIS_PORT 6379 --raw --allow-root
    wp redis enable --allow-root
fi
```

Installs and enables the Redis Object Cache plugin. Only runs on first install.

---

### Create second user

```bash
if ! wp user get "$WP_USER" --allow-root > /dev/null 2>&1; then
    wp user create "$WP_USER" "$WP_USER_EMAIL" \
        --user_pass="$WP_USER_PASSWORD" \
        --role=author \
        --allow-root
fi
```

Creates a second non-admin WordPress user. Required by the Inception subject.

---

### Start PHP-FPM

```bash
exec php-fpm8.2 -F
```

`exec` replaces the shell with PHP-FPM making it PID 1. `-F` runs it in foreground.

---

## Connection Flow

```
Nginx (port 443)
      ↓ FastCGI
WordPress PHP-FPM (port 9000)
      ↓              ↓
MariaDB (3306)    Redis (6379)
```

---

## Useful Evaluation Commands

### Check PHP-FPM is running
```bash
docker exec -it wordpress ps aux | grep php
```

### List WordPress users
```bash
docker exec -it wordpress wp user list --allow-root
```

### Check Redis cache status
```bash
docker exec -it wordpress wp redis status --allow-root
```

### Flush Redis cache
```bash
docker exec -it wordpress wp cache flush --allow-root
```

### Check installed plugins
```bash
docker exec -it wordpress wp plugin list --allow-root
```

### Check WordPress version
```bash
docker exec -it wordpress wp core version --allow-root
```

### Verify wp-config.php exists
```bash
docker exec -it wordpress cat /var/www/html/wp-config.php | grep DB_
```

### Check PHP-FPM is listening on port 9000
```bash
docker exec -it wordpress ss -tlnp | grep 9000
```