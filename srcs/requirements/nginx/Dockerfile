FROM debian:bookworm

RUN apt-get update && apt-get install -y nginx openssl

# create SSL certificate
RUN mkdir -p /etc/nginx/ssl

RUN openssl req -x509 -nodes -days 365 \
	-newkey rsa:2048 \
	-keyout /etc/nginx/ssl/nginx.key \
	-out /etc/nginx/ssl/nginx.crt \
	-subj "/C=MA/ST=Casablanca/L=Casablanca/O=1337/OU=student/CN=localhost"

# copy config
COPY conf/nginx.conf /etc/nginx/nginx.conf

CMD ["nginx", "-g", "daemon off;"]
