# Developer Documentation

This guide covers setting up the Inception project from scratch, building and launching the Docker-based infrastructure, managing containers and volumes, and understanding data persistence.

## Prerequisites

Before you begin, ensure the following are available on your Linux environment:

**Required:**

- **Linux OS** — Debian/Ubuntu or compatible distribution
- **Docker** (20.x or higher) — Already installed and running
- **Docker Compose** (v2 plugin) — Already installed
- **make** — Already installed
- **sudo access** — Required for environment setup

This project is designed to run on a Linux VM as per the 42 curriculum requirements.

## Environment Setup from Scratch

### Step 1: Clone and Navigate to Repository

```bash
git clone <your-repo-url>
cd inception
```

### Step 2: Configure Local Domain Resolution

Add your development domain to your system's hosts file:

```bash
echo "127.0.0.1   anaamaja.42.fr" | sudo tee -a /etc/hosts
```

Replace `anaamaja.42.fr` with your actual domain if different.

### Step 3: Create Configuration Files

Create the `.env` file at `srcs/.env`:

```bash
touch srcs/.env
```

Fill it with the following variables. Replace all `your_*` values with your own:

```env
MYSQL_ROOT_PASSWORD=your_root_password
MYSQL_DATABASE=your_db_name
MYSQL_USER=your_db_user
MYSQL_PASSWORD=your_db_password
WP_URL=anaamaja.42.fr
WP_TITLE=your_site_title
WP_ADMIN_USER=your_admin_username
WP_ADMIN_PASSWORD=your_admin_password
WP_ADMIN_EMAIL=your_admin_email@example.com
WP_USER=your_user_username
WP_USER_EMAIL=your_user_email@example.com
WP_USER_PASSWORD=your_user_password
FTP_USER=your_ftp_user
FTP_PASSWORD=your_ftp_password
```

Ensure `srcs/.env` is in your `.gitignore` — **never commit credentials to version control**.

### Step 4: Create Data Directories

The `Makefile` creates these automatically on `make all`, but you can also prepare them manually:

```bash
mkdir -p /home/anaamaja/data/mariadb
mkdir -p /home/anaamaja/data/wordpress
```

These directories persist your database and WordPress files across container restarts.

## Build and Launch Using Makefile and Docker Compose

The project includes a `Makefile` that simplifies Docker Compose operations. The Compose configuration is located at `srcs/docker-compose.yml`.

### Start the full stack (build + run)

```bash
make all
```

This:
- Creates data directories
- Builds all Docker images from `srcs/requirements/`
- Starts all containers in dependency order
- First run may take several minutes

### Rebuild without cache (force fresh images)

```bash
make re
```

This performs a full clean rebuild of the stack and refreshes all services.

### Start without rebuilding

```bash
make up
```

Starts containers using existing images.

### Stop containers (keep data)

```bash
make down
```

### Full cleanup (remove containers, volumes, data)

```bash
make clean
```

Removes all containers, networks, and local data directories.

### View running containers

```bash
make ps
```

### Follow service logs in real-time

```bash
make logs
```

Press `Ctrl+C` to exit.

## Docker Compose Configuration

The `srcs/docker-compose.yml` file defines:

- **8 Services**: `mariadb`, `wordpress`, `nginx`, `redis`, `adminer`, `static-site`, `ftp`, `portainer`
- **1 Network**: `inception` (bridge network for inter-container communication)
- **2 Volumes**: `mariadb_data` and `wordpress_data` (bound to local `/home/anaamaja/data/` directories)

Each service reads environment variables from `srcs/.env` and has restart policies set to `always`.

## Container and Volume Management

### Inspect Running Containers

```bash
docker ps                    # List running containers
docker ps -a                 # List all containers (including stopped)
docker inspect <container>   # Detailed info (network, mounts, environment)
```

### Access Container Shells

```bash
docker exec -it mariadb bash      # MariaDB shell
docker exec -it wordpress bash    # WordPress shell
docker exec -it nginx sh          # NGINX shell
```

### View Container Logs

```bash
docker logs <container>      # View logs from a specific container
docker logs -f <container>   # Follow logs in real-time
```

### Manage Volumes

```bash
docker volume ls                      # List all volumes
docker volume inspect <volume_name>   # Inspect a specific volume
docker volume rm <volume_name>        # Remove a volume (containers must be stopped)
```

The volumes created by this stack are:

- `srcs_mariadb_data` → mounted at `/var/lib/mysql` inside MariaDB
- `srcs_wordpress_data` → mounted at `/var/www/html` inside WordPress (also used by Nginx, FTP)

### Manage Networks

```bash
docker network ls                     # List networks
docker network inspect inception      # Inspect the inception network
```

## Data Storage and Persistence

### Where Data Is Stored

All persistent data is stored on the host machine:

```
/home/anaamaja/data/
├── mariadb/      ← MariaDB database files
└── wordpress/    ← WordPress core, themes, plugins, uploads
```

### How Persistence Works

Each volume is a bind mount linking the host filesystem to container mountpoints:

```
Host (/home/anaamaja/data/)    ←→    Docker Volume    ←→    Container Path
─────────────────────────────────────────────────────────────────────────
/home/anaamaja/data/mariadb    ←→    mariadb_data    ←→    /var/lib/mysql
/home/anaamaja/data/wordpress  ←→    wordpress_data  ←→    /var/www/html
```

**Key Points:**

- When containers stop, data persists in these directories
- `make down` stops containers but keeps data intact
- `make clean` removes containers AND deletes data directories
- Restarting with `make up` resurrects containers with the existing data

### Verifying Persistence

After the stack is running:

1. Create a WordPress post via the admin panel
2. Run `make down`
3. Run `make up`
4. Visit your WordPress site — the post should still exist

This confirms volumes are working correctly.

## Project Architecture Overview

The Inception stack follows this communication flow:

```
┌─────────────────┐
│   Browser       │
└────────┬────────┘
         │ HTTPS/TLS (port 443)
         ▼
┌──────────────────────────┐
│  NGINX                   │  ← Single entry point
│  (TLS termination,       │     reverse proxy
│   reverse proxy)         │
└────────┬─────────────────┘
         │ FastCGI (port 9000)
         ▼
┌──────────────────────────┐
│  WordPress (PHP-FPM)     │  ← Application server
│  + Redis cache           │
└────────┬─────────────────┘
         │ MySQL protocol (port 3306)
         ▼
┌──────────────────────────┐
│  MariaDB                 │  ← Database
└──────────────────────────┘

All containers connect via: docker-network "inception" (bridge)

Adminer, Portainer, and the static-site are accessible through the NGINX reverse proxy.
The FTP service is exposed separately through ports 21 and 10000-10100.
```

## Key Project Files

- **Makefile** — Repository root; defines build and deployment targets
- **srcs/docker-compose.yml** — Docker Compose definition with all services
- **srcs/requirements/** — Dockerfile and configuration for each service:
  - `mariadb/Dockerfile` + `mariadb/tools/mariadb.sh` (initialization)
  - `wordpress/Dockerfile` + `wordpress/tools/wordpress.sh` (WP setup)
  - `nginx/Dockerfile` + `nginx/conf/nginx.conf` (web server config)
  - `bonus/redis/Dockerfile` (cache service)
  - `bonus/adminer/Dockerfile` (database admin tool)
  - `bonus/ftp/Dockerfile` + `bonus/ftp/tools/setup.sh` (FTP service)
  - `bonus/static-site/Dockerfile` (bonus static content)
  - `bonus/portainer/Dockerfile` (container management UI)

## Common Developer Tasks

**Rebuild a single service:**

```bash
docker compose -f srcs/docker-compose.yml build --no-cache mariadb
```

**Recreate containers without rebuilding:**

```bash
docker compose -f srcs/docker-compose.yml up --force-recreate
```

**Tail logs from multiple services:**

```bash
docker compose -f srcs/docker-compose.yml logs -f mariadb wordpress
```

**Remove dangling volumes and images:**

```bash
docker system prune -a --volumes
```

For end-user instructions, refer to USER_DOC.md.
