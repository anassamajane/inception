FROM debian:bookworm

RUN apt-get update && apt-get install -y \
    php \
    php-fpm \
    php-mysql \
    curl

# Download WordPress
RUN curl -O https://wordpress.org/latest.tar.gz \
    && tar -xvf latest.tar.gz \
    && mv wordpress /var/www/html \
    && rm latest.tar.gz

# Fix permissions
RUN chown -R www-data:www-data /var/www/html

# Configure PHP-FPM to listen on port 9000
RUN sed -i 's|listen = /run/php/php8.2-fpm.sock|listen = 9000|' /etc/php/8.2/fpm/pool.d/www.conf

CMD ["php-fpm8.2", "-F"]
