# Redis Service Explanation

## What is Redis?

Redis is an in-memory key-value store used as a cache.

In this project, Redis sits between WordPress and MariaDB:

```
WordPress request
      ↓
Check Redis cache
      ↓
  Hit? → Return cached data instantly (no DB query)
  Miss? → Query MariaDB → Store result in Redis → Return data
```

This dramatically reduces database queries and speeds up page loads.

---

## Dockerfile Explained

```dockerfile
FROM debian:bookworm
RUN apt-get update && apt-get install -y redis-server
CMD ["redis-server", "--bind", "0.0.0.0", "--protected-mode", "no"]
```

### --bind 0.0.0.0

By default Redis only listens on `127.0.0.1`.
This makes it accept connections from other containers on the Docker network.

### --protected-mode no

Protected mode blocks external connections when no password is set.
Disabled here because authentication is handled at the network level
(only containers on the `inception` network can reach Redis).

---

## How WordPress Uses Redis

The Redis Object Cache plugin intercepts all WordPress database queries:

1. WordPress needs data (posts, options, user info...)
2. Plugin checks Redis first using a unique cache key
3. If found (cache hit) — returns immediately, no DB query
4. If not found (cache miss) — queries MariaDB, stores result in Redis, returns data
5. Next request for same data hits Redis directly

### Cache keys look like:
```
wp:options:alloptions
wp:posts:1
wp:userlogins:admin
```

---

## Redis vs PHP-Redis vs Predis

Three ways PHP can talk to Redis:

- **PhpRedis** — C extension, fastest, needs `php-redis` package installed
- **Predis** — pure PHP library, bundled with the Redis Cache plugin, no extra install needed
- **Relay** — newer C extension, fastest of all

In this project we use **Predis** which comes bundled with the Redis Cache plugin.
Status shows `Client: Predis (v2.4.0)` and `Status: Connected` which confirms it works.

---

## Useful Evaluation Commands

### Check Redis is running
```bash
docker exec -it redis redis-cli ping
# Expected: PONG
```

### Monitor live Redis activity
```bash
docker exec -it redis redis-cli monitor
```
Shows every command WordPress sends to Redis in real time.
Open this, then refresh the WordPress site to see cache activity.

### Check Redis status from WordPress
```bash
docker exec -it wordpress wp redis status --allow-root
```
Expected output includes:
```
Status: Connected
Client: Predis
```

### Count cached keys
```bash
docker exec -it redis redis-cli dbsize
```
Shows how many items are cached. Should increase as you browse the site.

### List cached keys
```bash
docker exec -it redis redis-cli keys "*"
```

### Flush all cache
```bash
docker exec -it redis redis-cli FLUSHALL
```
Or from WordPress:
```bash
docker exec -it wordpress wp cache flush --allow-root
```

### Check Redis memory usage
```bash
docker exec -it redis redis-cli info memory | grep used_memory_human
```

### Check Redis is listening on port 6379
```bash
docker exec -it redis ss -tlnp | grep 6379
```