FROM debian:bookworm

RUN apt-get update && apt-get install -y mariadb-server

RUN mkdir -p /run/mysqld
RUN chown -R mysql:mysql /run/mysqld
RUN chown -R mysql:mysql /var/lib/mysql

COPY tools/mariadb.sh /mariadb.sh
RUN chmod +x /mariadb.sh

CMD ["/mariadb.sh"]
