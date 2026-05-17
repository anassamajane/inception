# User Documentation

## What Services Are Provided?

The Inception stack runs multiple services, each in its own isolated Docker container:

**NGINX** — A secure web server that serves as the only entry point into the infrastructure via HTTPS (port 443). All internal web services are accessed through NGINX. The FTP service is exposed separately for file transfers.

**WordPress** — The website application powered by PHP-FPM. It handles your site content, pages, posts, and user management. You cannot access it directly—it runs behind NGINX.

**MariaDB** — The database that stores all WordPress content, user accounts, settings, and posts. It only runs internally and is not exposed outside the Docker network.

**Redis** — A caching service that improves WordPress performance by storing frequently accessed data in memory. This reduces database queries and speeds up page loading.

**Adminer** — A web-based database management tool. You can use it to view and manage your MariaDB database directly through a browser interface.

**FTP Server** — A file transfer service that allows you to upload, download, and manage WordPress files directly from your computer.

**Static Website** — A bonus static content site accessible alongside your WordPress site through the Nginx proxy.

**Portainer** — A Docker container management interface that lets you view and control running containers.

All services communicate over a private Docker network. Only NGINX and the FTP service are exposed externally. All other services remain internal to the Docker network.

## Starting the Project

Before you start, make sure Docker is running on your machine. You can verify this by running:

```sh
docker info
```

If you see an error, start the Docker service:

```sh
sudo systemctl start docker
```

Once Docker is running, start the entire stack from the repository root:

```sh
make all
```

This command will:
- Create the necessary data directories on your host machine
- Build the Docker images (if not already built)
- Start all containers (NGINX, WordPress, MariaDB, Redis, Adminer, FTP, Static-site, and Portainer)

The first run may take a few minutes while Docker builds the images. You will see messages as each service starts up.

## Stopping the Project

**Stop containers but keep your data:**

```sh
make down
```

This stops all running containers but preserves your database and WordPress files. You can start them again with `make up` and your data will still be there.

**Stop containers and remove all volumes:**

```sh
make clean
```

This removes all containers, networks, and local data. Your WordPress database and files will be deleted. Use this if you want a fresh start.

**Complete reset (remove everything including images):**

```sh
make fclean
```

This is the nuclear option—all containers, volumes, images, and local data under `/home/anaamaja/data/` will be deleted. Only use this if you want to completely wipe everything.

## Accessing the Website and Admin Panel

Once the project is running, open your browser and navigate to your domain:

```
https://your_domain.42.fr
```

Replace `your_domain.42.fr` with the actual domain or IP address configured in `srcs/.env`.

Your browser may show a security warning about the certificate. This is expected because the project uses a self-signed TLS certificate for development. Click "Advanced" or "Accept the Risk and Continue" (wording varies by browser) to proceed.

You should see your WordPress homepage.

**Accessing the WordPress admin panel:**

Go to:

```
https://your_domain.42.fr/wp-admin/
```

Log in with your WordPress admin username and password (defined in `srcs/.env`). From the admin panel you can:

- Create, edit, and delete posts and pages
- Manage users and their roles
- Install and activate themes and plugins
- Customize site appearance and settings
- Monitor site activity

**Accessing Adminer for database management:**

Adminer lets you manage your MariaDB database through a web interface. Go to:

```
https://your_domain.42.fr/adminer/
```

On the login page, select "MySQL" or "MariaDB" from the System dropdown, then enter:

- **Server:** `mariadb`
- **Username:** Your database user (from `srcs/.env`)
- **Password:** Your database password (from `srcs/.env`)
- **Database:** Your database name (from `srcs/.env`)

Click "Login" to access your database.

**Accessing the Static Website:**

```
https://your_domain.42.fr/static-site/
```

## Locating and Managing Credentials

All credentials are defined in the `srcs/.env` file. This file contains sensitive information and should never be shared or committed to version control.

**WordPress Admin Account:**

Your admin username and password are defined in `srcs/.env` as `WP_ADMIN_USER` and `WP_ADMIN_PASSWORD`. Use these to log in at `/wp-admin/`.

**WordPress Regular User Account:**

A second user account is created automatically with credentials `WP_USER` and `WP_USER_PASSWORD`.

**Database Credentials:**

Your database name, username, and password are defined as `MYSQL_DATABASE`, `MYSQL_USER`, and `MYSQL_PASSWORD` in `srcs/.env`. Use these when accessing Adminer.

**FTP Credentials:**

Your FTP server credentials are `FTP_USER` and `FTP_PASSWORD` in `srcs/.env`.

**Important Security Notes:**

- Never share or commit the `srcs/.env` file to Git.
- Never share these credentials with anyone you don't trust.
- If you suspect a credential has been compromised, regenerate it and update `srcs/.env`, then run `make down` and `make all` to restart with new credentials.

## Checking That Services Are Running Correctly

**List all running containers:**

```sh
make ps
```

You should see all containers with status "Up". If any show "Exited", there is a problem.

**View service logs:**

```sh
make logs
```

This shows real-time logs from all services. You can scroll up to see past messages and spot error messages. Press `Ctrl+C` to exit.

**Quick health check:**

1. Open your WordPress site in a browser — does it load?
2. Try accessing the admin panel — can you log in?
3. Try accessing Adminer — can you connect to the database?
4. Run `docker ps` — do you see all containers running?
5. Check that data directories exist:
   ```sh
   ls /home/anaamaja/data/
   ```
   You should see `mariadb` and `wordpress` directories. These contain your persistent data.

If something isn't working, check the logs with `make logs` and look for error messages.

## Using FTP to Manage Files

You can use FTP to upload, download, and manage WordPress files directly from your computer.

**Installing FTP client:**

On Linux, install the FTP command-line client:

```sh
sudo apt install ftp
```

**Connecting via FTP:**

```sh
ftp your_domain.42.fr
```

Enter your FTP username and password when prompted. You will be placed in the WordPress directory inside the FTP user home, not the container root.

**Uploading files:**

You can upload files using FTP. For example, to upload a test PHP file:

```sh
put test.php
```

Or use `curl` from your terminal:

```sh
curl -u your_ftp_user:your_ftp_password -T test.php ftp://your_domain.42.fr/
```

**Downloading files:**

To download files from the server:

```sh
get filename.php
```

Or with `curl`:

```sh
curl -u your_ftp_user:your_ftp_password -O ftp://your_domain.42.fr/filename.php
```

**Exiting FTP:**

Type `bye` to disconnect.

## Data Persistence

Your WordPress files and database are stored in persistent Docker volumes that survive container restarts:

- WordPress files are stored in `/home/anaamaja/data/wordpress/`
- Database data is stored in `/home/anaamaja/data/mariadb/`

When you stop containers with `make down`, this data is preserved. When you restart with `make up`, your data is still there.

Only the `make clean` command deletes these directories. Use it only when you want to start completely fresh.

## For Advanced Configuration

If you need to modify the Docker setup, rebuild containers, manage volumes manually, or understand the technical architecture, refer to DEV_DOC.md.
