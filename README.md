# Inception

*This project has been created as part of the 42 curriculum by anaamaja*

## Description

This project involves setting up a small infrastructure composed of different services using Docker Compose. The goal is to create a fully functional web application stack with WordPress as the CMS, MariaDB as the database, and NGINX as the web server with SSL/TLS encryption.

## Instructions

### Prerequisites
- Docker and Docker Compose installed
- Linux/Unix environment
- Domain name configured (anaamaja.42.fr pointing to localhost)

### Installation and Execution
1. Clone the repository
2. Navigate to the inception directory
3. Run `make` to set up and start all services
4. Access the application at https://anaamaja.42.fr

### Build Commands
- `make all`: 
- `make up`: 
- `make down`: 
- `make clean`: 
- `make fclean`: 

## Resources

### Classic References
- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [WordPress Developer Resources](https://developer.wordpress.org/)
- [NGINX Documentation](https://nginx.org/en/docs/)
- [MariaDB Documentation](https://mariadb.com/kb/en/documentation/)

### AI Usage
AI was used to assist with:
- Docker configuration optimization and best practices
- Script debugging and error resolution
- Documentation structure and content generation
- Code review and improvement suggestions

## Project Description

This project uses Docker to build and run each service inside its own container. The source files are organized under `srcs/`, with one Dockerfile per service and a single `docker-compose.yml` file to orchestrate the stack.

### Docker Usage and Project Sources

The stack uses Docker Compose to create an isolated network for all services. The main source files are:

- `srcs/docker-compose.yml` — defines services, networks, and volumes
- `srcs/.env` — stores runtime configuration and credentials
- `srcs/requirements/nginx/` — NGINX Dockerfile and SSL configuration
- `srcs/requirements/wordpress/` — WordPress container with PHP-FPM and setup script
- `srcs/requirements/mariadb/` — MariaDB container and initialization script
- `srcs/requirements/bonus/` — additional services like Redis, Adminer, FTP, static website, and portainer

### Main Design Choices

- **Microservices Architecture**: Each service is isolated in its own container for better maintainability and separation of concerns.
- **Reverse Proxy**: NGINX handles HTTPS termination and routes requests to WordPress, Adminer, and the static website.
- **Data Persistence**: WordPress and MariaDB data are stored on host-bound directories so data remains after container restarts.

### Comparisons

#### Virtual Machines vs Docker
- **Virtual Machines**: Run full guest OS instances, use more resources, and take longer to start.
- **Docker**: Runs lightweight containers sharing the host kernel, with faster startup and lower overhead.

#### Secrets vs Environment Variables
- **Secrets**: More secure for sensitive information, usually hidden and managed separately from service configuration.
- **Environment Variables**: Easier for development and configuration, but less secure because they are visible in container metadata and `.env` files.

#### Docker Network vs Host Network
- **Docker Network**: Provides isolated networking and service discovery by container name, which is safer and more flexible.
- **Host Network**: Uses the host network stack directly, which can improve performance but reduces isolation and increases port conflict risk.

#### Docker Volumes vs Bind Mounts
- **Docker Volumes**: Managed by Docker, good for persistent storage and portability across hosts.
- **Bind Mounts**: Directly map host filesystem paths into containers, useful for development and direct file access, but less portable.