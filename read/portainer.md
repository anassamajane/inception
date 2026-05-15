# Portainer Service Explanation

## What is Portainer?

Portainer is a web-based Docker management UI.

It allows you to manage your entire Docker infrastructure visually:
* view and manage containers (start, stop, restart, delete)
* inspect images
* manage volumes
* manage networks
* view container logs
* open a console inside a container
* monitor resource usage

---

## Dockerfile Explained

```dockerfile
FROM debian:bookworm
RUN apt-get update && apt-get install -y curl tar
RUN curl -L https://github.com/portainer/portainer/releases/download/2.27.6/portainer-2.27.6-linux-amd64.tar.gz \
    -o portainer.tar.gz
RUN mkdir /portainer \
    && tar -xvf portainer.tar.gz -C /portainer --strip-components=1
WORKDIR /portainer
CMD ["./portainer"]
```

Downloads and extracts the Portainer binary, then runs it directly.

---

## Docker Socket Mount

```yaml
volumes:
  - /var/run/docker.sock:/var/run/docker.sock
```

This is the key that makes Portainer work.

`/var/run/docker.sock` is the Unix socket that Docker daemon listens on.
By mounting it inside the Portainer container, Portainer can send commands
directly to the Docker daemon on the host — allowing it to see and manage
all containers, images, volumes, and networks.

Without this mount, Portainer would start but see nothing.

---

## How to Access

URL: `https://anaamaja.42.fr/portainer/`

On first visit, Portainer asks you to create an admin password.
After login, select "local" environment to manage the Docker host.

---

## What You Can Show During Evaluation

### Containers view
Shows all running containers with their status, uptime, CPU and memory usage.

### Networks view
Shows the `inception` bridge network with all connected containers.

### Volumes view
Shows `srcs_mariadb_data` and `srcs_wordpress_data` volumes.

### Images view
Shows all built images: mariadb, wordpress, nginx, redis, adminer, ftp, portainer, static-site.

### Container console
Click on any container → Console → Connect.
Opens a terminal inside the container directly from the browser.

### Container logs
Click on any container → Logs.
Shows the same output as `docker logs <container>`.

---

## Why Portainer is Useful

Justification for evaluation:

> "Portainer provides a centralized management interface for my entire Docker infrastructure.
> Instead of running multiple docker commands to inspect containers, networks and volumes,
> I can monitor and manage everything from a single web UI. It's particularly useful for
> troubleshooting — I can read logs and open console sessions without needing CLI access."

---

## Useful Evaluation Commands

### Verify Portainer container is running
```bash
docker ps | grep portainer
```

### Check Docker socket is mounted
```bash
docker exec -it portainer ls /var/run/docker.sock
```

### Check Portainer is listening on port 9000
```bash
docker exec -it portainer ss -tlnp | grep 9000
```

### Verify Portainer can see Docker
```bash
docker exec -it portainer /portainer/portainer --version
```