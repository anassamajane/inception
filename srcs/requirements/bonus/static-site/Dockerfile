FROM debian:bookworm

RUN apt-get update && apt-get install -y nginx

COPY site /var/www/html

CMD ["nginx", "-g", "daemon off;"]