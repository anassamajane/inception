FROM debian:bookworm

RUN apt-get update && apt-get install -y redis-server

CMD ["redis-server", "--bind", "0.0.0.0", "--protected-mode", "no"]
