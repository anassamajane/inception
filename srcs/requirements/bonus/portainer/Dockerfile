FROM debian:bookworm

RUN apt-get update && apt-get install -y curl tar

RUN curl -L https://github.com/portainer/portainer/releases/download/2.27.6/portainer-2.27.6-linux-amd64.tar.gz \
    -o portainer.tar.gz

RUN mkdir /portainer \
    && tar -xvf portainer.tar.gz -C /portainer --strip-components=1

WORKDIR /portainer

CMD ["./portainer"]
