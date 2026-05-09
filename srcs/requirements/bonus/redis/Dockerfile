FROM debian:bookworm

RUN apt-get update && apt-get install -y redis-server

# configure redis to accept connections
RUN sed -i 's/^bind .*/bind 0.0.0.0/' /etc/redis/redis.conf \
 && sed -i 's/^protected-mode yes/protected-mode no/' /etc/redis/redis.conf

CMD ["redis-server"]
