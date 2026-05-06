#!/bin/bash

set -e
set -x

#start Mariadb in background
mysqld_safe --user=mysql &

# Wait until ready
until mysqladmin ping --silent; do
    sleep 1
done

# check if database exists
if ! mysql -u root -p"$MYSQL_ROOT_PASSWORD" -e "USE $MYSQL_DATABASE;" 2>/dev/null; then
    # first run - root has no password yet, init everything
    mysql <<EOF
CREATE DATABASE $MYSQL_DATABASE;
CREATE USER '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD';
GRANT ALL PRIVILEGES ON $MYSQL_DATABASE.* TO '$MYSQL_USER'@'%';
ALTER USER 'root'@'localhost' IDENTIFIED BY '$MYSQL_ROOT_PASSWORD';
FLUSH PRIVILEGES;
EOF
fi

# restart MariaDB
mysqladmin -u root -p"$MYSQL_ROOT_PASSWORD" shutdown

# Start MariaDB
exec mysqld --user=mysql
