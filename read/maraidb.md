# MariaDB Service Explanation

## What is MariaDB?

MariaDB is an open-source relational database — a fork of MySQL.

In this project, MariaDB:

* stores all WordPress content (posts, pages, users, settings)
* is only accessible internally by the WordPress container
* is never exposed to the outside world

---

## Dockerfile Explained

### Install MariaDB

```dockerfile
RUN apt-get update && apt-get install -y mariadb-server
```

Installs the MariaDB server package.

---

### Create runtime directory

```dockerfile
RUN mkdir -p /run/mysqld
RUN chown -R mysql:mysql /run/mysqld
RUN chown -R mysql:mysql /var/lib/mysql
```

`/run/mysqld` is where MariaDB stores its socket file and PID file at runtime.
Ownership is set to the `mysql` user because MariaDB runs as `mysql`, not root.

---

### Configure bind address

```dockerfile
RUN sed -i 's/^bind-address.*/bind-address=0.0.0.0/' /etc/mysql/mariadb.conf.d/50-server.cnf
```

By default MariaDB only listens on `127.0.0.1` (localhost inside the container).
This changes it to `0.0.0.0` so the WordPress container can reach it over the Docker network.

---

## mariadb.sh Script Explained

### Start MariaDB in background

```bash
mysqld_safe --user=mysql &
```

Starts MariaDB temporarily in the background for the init phase.

---

### Wait until ready

```bash
until mysqladmin ping --silent; do
    sleep 1
done
```

Waits until MariaDB is accepting connections before running SQL commands.

---

### First run check

```bash
if ! mysql -u root -p"$MYSQL_ROOT_PASSWORD" -e "USE $MYSQL_DATABASE;" 2>/dev/null; then
```

On first run, root has no password yet so this check fails and we enter the init block.
On second run, root has a password and the database exists so we skip init entirely.
This prevents re-initializing the database on every container restart.

---

### Init block (heredoc)

```sql
CREATE DATABASE $MYSQL_DATABASE;
CREATE USER '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD';
GRANT ALL PRIVILEGES ON $MYSQL_DATABASE.* TO '$MYSQL_USER'@'%';
ALTER USER 'root'@'localhost' IDENTIFIED BY '$MYSQL_ROOT_PASSWORD';
FLUSH PRIVILEGES;
```

All SQL runs in a single session. Root has no password when the session opens so auth
succeeds, then root password is set within that same authenticated session.

- `CREATE DATABASE` — creates the WordPress database
- `CREATE USER` — creates the WordPress user accessible from any host (%)
- `GRANT ALL PRIVILEGES` — gives the user full control over the database
- `ALTER USER` — sets the root password
- `FLUSH PRIVILEGES` — applies all permission changes immediately

---

### Restart cleanly

```bash
mysqladmin -u root -p"$MYSQL_ROOT_PASSWORD" shutdown
exec mysqld --user=mysql
```

Shuts down the temporary background instance, then starts the final MariaDB as PID 1
in foreground using `exec`.

---

## Useful Evaluation Commands

### Connect to MariaDB as root
```bash
docker exec -it mariadb mysql -u root -proot123
```

### List databases
```bash
docker exec -it mariadb mysql -u root -proot123 -e "SHOW DATABASES;"
```

### Check WordPress database tables
```bash
docker exec -it mariadb mysql -u root -proot123 -e "USE mydb; SHOW TABLES;"
```

### Check users exist
```bash
docker exec -it mariadb mysql -u root -proot123 -e "SELECT User, Host FROM mysql.user;"
```

### Connect as WordPress user
```bash
docker exec -it mariadb mysql -u anass -p1234 mydb
```

### Check MariaDB is listening on 0.0.0.0
```bash
docker exec -it mariadb ss -tlnp | grep 3306
```

### Check WordPress posts in database
```bash
docker exec -it mariadb mysql -u root -proot123 -e "SELECT ID, post_title, post_status FROM mydb.wp_posts WHERE post_status='publish';"
```

### Check bind address in config
```bash
docker exec -it mariadb grep bind-address /etc/mysql/mariadb.conf.d/50-server.cnf
```