# Nginx Service Explanation

## What is Nginx?

Nginx is a high-performance web server and reverse proxy.

In this project, Nginx is the **only entry point** from the outside world. It:

* serves the WordPress site over HTTPS
* proxies PHP requests to the WordPress container
* proxies bonus services (Adminer, Portainer, static site)
* enforces TLS encryption

---

## Dockerfile Explained

### Install nginx and openssl

```dockerfile
RUN apt-get update && apt-get install -y nginx openssl
```

* `nginx` — the web server
* `openssl` — tool to generate SSL certificates

---

### Generate self-signed SSL certificate

```dockerfile
RUN openssl req -x509 -nodes -days 365 \
    -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/nginx.key \
    -out /etc/nginx/ssl/nginx.crt \
    -subj "/C=MA/ST=Marrakesh-Safi/L=Benguerir/O=42/OU=1337/CN=anaamaja.42.fr"
```

| Flag | Meaning |
|------|---------|
| `-x509` | Generate self-signed cert (not a CA request) |
| `-nodes` | No password on private key (nginx loads it automatically) |
| `-days 365` | Certificate valid for 1 year |
| `-newkey rsa:2048` | Generate new 2048-bit RSA private key |
| `-keyout` | Where to save the private key |
| `-out` | Where to save the certificate |
| `-subj` | Skip interactive prompt, fill certificate fields directly |

---

### Start nginx in foreground

```dockerfile
CMD ["nginx", "-g", "daemon off;"]
```

By default nginx runs as a background daemon and exits immediately.

`daemon off;` keeps nginx in the foreground so Docker sees it as a running process.

---

## nginx.conf Explained

### include mime.types

```nginx
include /etc/nginx/mime.types;
```

Tells nginx the correct Content-Type for each file extension:
* `.css` → `text/css`
* `.js` → `application/javascript`
* `.png` → `image/png`

Without this, browsers may refuse to apply CSS/JS files.

---

### listen 443 ssl

```nginx
listen 443 ssl;
```

Nginx listens on port 443 (HTTPS only). Port 80 (HTTP) is never opened.

---

### TLS restriction

```nginx
ssl_protocols TLSv1.2 TLSv1.3;
```

Only accepts TLS 1.2 and 1.3. Older versions (1.0, 1.1) are rejected. Required by the Inception subject.

---

### WordPress location blocks

```nginx
location / {
    try_files $uri $uri/ /index.php?$args;
}
```

Try to serve the file directly. If not found, pass to WordPress (index.php).

```nginx
location ~ \.php$ {
    fastcgi_pass wordpress:9000;
    fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
}
```

All `.php` files are forwarded to the WordPress container via FastCGI on port 9000.

---

### Bonus proxy locations

```nginx
location /static-site/ {
    proxy_pass http://static-site/;
}
location /adminer/ {
    proxy_pass http://adminer:9000/;
}
location /portainer/ {
    proxy_pass http://portainer:9000/;
}
```

Nginx acts as a reverse proxy — requests to these paths are forwarded to the respective containers internally.

---

## Traffic Flow

```
Browser (HTTPS:443)
        ↓
      Nginx
        ↓
  ┌─────┼──────────────┐
  ↓     ↓              ↓
PHP:9000  /adminer   /portainer
WordPress  Adminer    Portainer
```

---

## Useful Evaluation Commands

### Verify nginx is running
```bash
docker exec -it nginx nginx -t
```
Tests the nginx configuration syntax.

### Check nginx is listening on 443
```bash
docker exec -it nginx ss -tlnp | grep 443
```

### Check TLS version
```bash
openssl s_client -connect anaamaja.42.fr:443 -tls1_2
openssl s_client -connect anaamaja.42.fr:443 -tls1_3
```
Both should connect successfully.

### Verify TLS 1.0 is rejected
```bash
openssl s_client -connect anaamaja.42.fr:443 -tls1
```
Should fail — connection refused.

### View the SSL certificate
```bash
openssl s_client -connect anaamaja.42.fr:443 < /dev/null 2>/dev/null | openssl x509 -text | grep -E "Subject|Issuer|Not"
```

### Check nginx logs
```bash
docker logs nginx
```