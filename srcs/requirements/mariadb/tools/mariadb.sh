#!/bin/bash

#start Mariadb in background
mysqld_safe --user=mysql &

# check if DB is already initialized
if [ ! -d "/var/lib/mysql/mysql"]; then
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
