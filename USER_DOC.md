# USER_DOC — User & Administrator Documentation

## What Services Are Running?

| Service | Container | Role | Port |
|---------|-----------|------|------|
| NGINX | `nginx` | HTTPS reverse proxy, sole entry point | 443 (public) |
| WordPress + PHP-FPM | `wordpress` | Web application | 9000 (internal only) |
| MariaDB | `mariadb` | Database | 3306 (internal only) |

Only port **443** is accessible from outside. The other ports are only reachable between containers inside the Docker network.

---

## Starting and Stopping the Project

### Start everything
```bash
make
```
This builds the Docker images (first time takes a few minutes) and starts all containers in the background.

### Stop everything (keeps data)
```bash
make down
```
Containers stop but your database and WordPress files are preserved.

### Full reset (destroys all data)
```bash
make clean
```
Stops containers, removes images, removes volumes, and deletes all data from `/home/yourlogin/data/`. Use this only if you want to start completely fresh.

### Rebuild from scratch
```bash
make re
```
Equivalent to `make clean` followed by `make`.

---

## Accessing the Website

1. Open your browser and go to: `https://yourlogin.42.fr`
2. You will see a browser warning about the self-signed SSL certificate — this is expected. Click **Advanced → Proceed** (or equivalent in your browser).
3. You should see the WordPress site homepage.

### WordPress Admin Panel
- URL: `https://yourlogin.42.fr/wp-admin`
- Log in with the admin credentials from `secrets/credentials.txt`
- The admin username is defined in `srcs/.env` as `WP_ADMIN_USER`

---

## Credentials

All credentials are stored **locally** and **never committed to git**.

| What | Where |
|------|-------|
| WordPress admin password | `secrets/credentials.txt` |
| MariaDB user password | `secrets/db_password.txt` |
| MariaDB root password | `secrets/db_root_password.txt` |
| Admin username | `srcs/.env` → `WP_ADMIN_USER` |
| Regular user password | `srcs/.env` → `WP_USER_PASS` |

---

## Checking That Services Are Running

### Quick status check
```bash
make ps
# or
cd srcs && docker compose ps
```
All three services should show status `Up`.

### Check logs
```bash
make logs
# or per-service:
cd srcs && docker compose logs nginx
cd srcs && docker compose logs wordpress
cd srcs && docker compose logs mariadb
```

### Test HTTPS is working
```bash
curl -k https://yourlogin.42.fr
# Should return HTML output from WordPress
```

### Connect to the database directly (for inspection)
```bash
docker exec -it mariadb mariadb -u wpuser -p wordpress
# Enter the password from secrets/db_password.txt
```

### Verify two WordPress users exist
```bash
docker exec -it wordpress wp user list --allow-root
# Should show your admin user and a second regular user
```
