#!/bin/bash

#start Mariadb in background
mysqld_safe --user=mysql &

# Wait until ready
until mysqladmin ping --silent; do
    sleep 1
done

# check if database exists
if ! mysql -e "USE $MYSQL_DATABASE;" 2>/dev/null; then
	echo "Initializing database..."

	mysql -e "CREATE DATABASE $MYSQL_DATABASE;"
	mysql -e "CREATE USER '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD';"
	mysql -e "GRANT ALL PRIVILEGES ON $MYSQL_DATABASE.* TO '$MYSQL_USER'@'%';"
	mysql -e "FLUSH PRIVILEGES;"
fi

# restart MariaDB
mysqladmin -u root shutdown

# Start MariaDB
exec mysqld --user=mysql
