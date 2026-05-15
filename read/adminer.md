# Adminer Service Explanation

## What is Adminer?

Adminer is a lightweight database management web UI — a single PHP file.

It lets you:
* browse database tables
* run SQL queries
* inspect table structure
* view and edit records
* manage users and permissions

Think of it as a simple phpMyAdmin alternative.

---

## Dockerfile Explained

```dockerfile
FROM debian:bookworm
RUN apt-get update && apt-get install -y php curl php-mysqli
RUN mkdir -p /var/www/html
RUN curl -L https://github.com/vrana/adminer/releases/download/v4.8.1/adminer-4.8.1.php \
    -o /var/www/html/index.php
WORKDIR /var/www/html
CMD ["php", "-S", "0.0.0.0:8080", "-t", "/var/www/html"]
```

### php-mysqli

PHP extension that allows PHP to connect to MySQL/MariaDB.
Without it, Adminer cannot connect to the database and shows:
```
None of the supported PHP extensions (MySQLi, MySQL, PDO_MySQL) are available.
```

### Download adminer.php as index.php

The entire Adminer application is a single PHP file.
Renamed to `index.php` so PHP's built-in server serves it as the default page.

### PHP built-in server

```dockerfile
CMD ["php", "-S", "0.0.0.0:8080", "-t", "/var/www/html"]
```

- `-S 0.0.0.0:8080` — start built-in web server on port 8080
- `-t /var/www/html` — set document root to `/var/www/html`

No nginx or apache needed — PHP serves itself.

---

## How to Access

URL: `https://anaamaja.42.fr/adminer/`

Login credentials:
- System: `MySQL`
- Server: `mariadb`
- Username: `anass`
- Password: `1234`
- Database: `mydb`

---

## Important Note

Adminer directly modifies the database — it bypasses WordPress completely.

If you delete or modify content via Adminer, WordPress Redis cache still holds the old data.
Always flush cache after direct database changes:

```bash
docker exec -it wordpress wp cache flush --allow-root
```

The proper way to manage WordPress content is through the WordPress dashboard.
Adminer is for inspecting and verifying the database structure during evaluation.

---

## Useful Evaluation Commands

### Check Adminer container is running
```bash
docker exec -it adminer php -v
```

### Check Adminer is listening on port 8080
```bash
docker exec -it adminer ss -tlnp | grep 8080
```

### Verify adminer.php file exists
```bash
docker exec -it adminer ls -la /var/www/html/
```

### Check php-mysqli is installed
```bash
docker exec -it adminer php -m | grep mysqli
```

### Test connection to MariaDB from Adminer container
```bash
docker exec -it adminer php -r "
\$conn = new mysqli('mariadb', 'anass', '1234', 'mydb');
if (\$conn->connect_error) {
    echo 'Failed: ' . \$conn->connect_error;
} else {
    echo 'Connected successfully';
}
"
```