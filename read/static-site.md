# Static Site Service Explanation

## What is the Static Site?

A simple static website served by Nginx.

It is:
* written in HTML and CSS only
* not PHP, not WordPress
* completely independent from the rest of the infrastructure
* a personal resume/portfolio page

Required by the Inception subject:
> "Create a simple static website in the language of your choice except PHP."

---

## Dockerfile Explained

```dockerfile
FROM debian:bookworm
RUN apt-get update && apt-get install -y nginx
COPY site /var/www/html
CMD ["nginx", "-g", "daemon off;"]
```

### Why its own nginx?

This container has its own nginx instance separate from the main nginx container.
It serves static HTML/CSS files directly — no PHP, no FastCGI, no database.

### COPY site /var/www/html

Copies all static files (index.html, style.css, images...) into the container at build time.
The files are baked into the image — no volume needed.

### daemon off

Keeps nginx in the foreground so Docker keeps the container alive.

---

## How to Access

URL: `https://anaamaja.42.fr/static-site/`

The main nginx proxies requests to this container:
```nginx
location /static-site/ {
    proxy_pass http://static-site/;
}
```

---

## Difference From WordPress

| Feature | WordPress | Static Site |
|---------|-----------|-------------|
| Language | PHP | HTML/CSS |
| Database | MariaDB | None |
| Dynamic content | Yes | No |
| Updates | Via dashboard | Via Docker rebuild |
| Server | PHP-FPM + Nginx | Nginx only |

---

## Useful Evaluation Commands

### Check static-site nginx is running
```bash
docker exec -it static-site nginx -t
```
Tests the nginx configuration.

### Verify HTML files are present
```bash
docker exec -it static-site ls -la /var/www/html/
```

### Check nginx is listening on port 80
```bash
docker exec -it static-site ss -tlnp | grep 80
```

### Verify content is served
```bash
docker exec -it static-site curl -s http://localhost/ | head -20
```

### Check no PHP in the container
```bash
docker exec -it static-site which php
# Should return nothing — PHP is not installed
```