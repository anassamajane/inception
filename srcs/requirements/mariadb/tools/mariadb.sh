#!/bin/bash

#start Mariadb in background
mysqld_safe --user=mysql &

# check if DB is already initialized
if [ ! -d "/var/lib/mysql/mysql"]; then
	echo "Initializing database..."

# run SQL commands
mysql -e "CREATE DATABASE mydb;"
mysql -e "CREATE USER 'myuser'@'%' IDENTIFIED BY 'mypassword';"
mysql -e "GRANT ALL PRIVILEGES ON mydb.* TO 'myuser'@'%';"
mysql -e "FLUSH PRIVILEGES;"

fi

# restart MariaDB
mysqladmin -u root shutdown

# Start MariaDB
exec mysqld --user=mysql
