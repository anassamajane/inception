*This project has been created as part of the 42 curriculum by anaamaja.*

# Inception

## Description

This repository contains the Inception project stack implemented using Docker and Docker Compose. The goal is to deploy a small web application ecosystem that includes a WordPress site, MariaDB database, Nginx web server, Redis cache, Adminer administration tool, Portainer management UI, an FTP service, and a static bonus site.

The project demonstrates Docker-based service orchestration, container networking, data persistence, and automated service startup. It packages multiple containers and shared volumes under a single `srcs/docker-compose.yml` stack and uses a `Makefile` to simplify build and deploy operations.

## Instructions

1. Place this repository root in a Linux environment with Docker and Docker Compose installed.
2. Create a `srcs/.env` file with the required service environment variables. Example variables include:
   - `MYSQL_ROOT_PASSWORD`
   - `MYSQL_DATABASE`
   - `MYSQL_USER`
   - `MYSQL_PASSWORD`
   - `WP_URL`
   - `WP_TITLE`
   - `WP_ADMIN_USER`
   - `WP_ADMIN_PASSWORD`
   - `WP_ADMIN_EMAIL`
   - `WP_USER`
   - `WP_USER_EMAIL`
   - `WP_USER_PASSWORD`
   - `FTP_USER`
   - `FTP_PASSWORD`
3. Run `make all` from the repository root to create the local data directories, build all images, and launch the stack.
4. Use `make up` to start containers without rebuilding.
5. Use `make down` to stop the stack.
6. Use `make clean` to stop the stack and remove containers, networks, Docker volumes, and bind-mounted local data.
7. Use `make ps` to inspect running containers and `make logs` to follow service logs.

## Services Included

- `mariadb`: MariaDB database service.
- `wordpress`: WordPress PHP/FPM application.
- `nginx`: Nginx reverse proxy and SSL entrypoint.
- `redis`: Redis cache service for WordPress.
- `adminer`: Database administration tool.
- `static-site`: A simple static bonus website.
- `ftp`: FTP server for file transfer.
- `portainer`: Docker management UI.

## Project Description

This Inception project uses Docker to isolate services and control dependencies while enabling repeatable deployment. Each service is built from a Dockerfile in `srcs/requirements/`, and `srcs/docker-compose.yml` defines service relationships, shared volumes, and the project network.

The stack is designed around a single Docker network named `inception`, allowing containers to communicate by service name. Persisted data is stored on local Docker volumes bound to directories under `/home/anaamaja/data`, which keeps WordPress and MariaDB data safe across container restarts.

## Docker Design Choices

### Virtual Machines vs Docker

- Docker is used because it is lighter, faster to start, and easier to manage for this multi-service web stack. Containers share the host kernel and require fewer resources than full virtual machines.
- Virtual Machines provide stronger isolation and can run different kernels, but they are heavier and slower to provision. For this project, Docker is the better choice for development and deployment of the stack.

### Secrets vs Environment Variables

- Environment variables are used for configuration values such as database credentials and WordPress settings. This is convenient for Docker Compose and build-time container setup.
- Secrets are preferable for production-grade deployments because they reduce exposure of sensitive values and can be managed securely by orchestration platforms. This repository avoids storing real secrets and expects the user to define non-sensitive values in `srcs/.env`.

### Docker Network vs Host Network

- The `inception` user-defined bridge network is used so containers can resolve each other by service name and remain isolated from other host services.
- Host network mode would expose container ports directly on the host network stack and can be less secure. For this stack, Docker networking provides safer service separation and easier container-to-container communication.

### Docker Volumes vs Bind Mounts

- Docker volumes are used with bind mount driver options to persist database and WordPress files on the host filesystem. This keeps application data outside the container lifecycle.
- Bind mounts expose specific host directories directly into containers, which can simplify development but may be less portable. The current setup uses bind-backed Docker volumes to combine persistence with easier control over storage location.

## Resources

- Docker documentation: https://docs.docker.com
- Docker Compose documentation: https://docs.docker.com/compose/
- WordPress documentation: https://developer.wordpress.org/
- MariaDB documentation: https://mariadb.com/kb/en/
- Nginx documentation: https://nginx.org/en/docs/
- Adminer: https://www.adminer.org/

### AI Usage

AI was used to assist with:

- Docker configuration optimization and best practices
- Debugging and resolving shell script and container startup issues
- Structuring documentation for clarity and subject compliance
- Reviewing Docker Compose and service configuration details
