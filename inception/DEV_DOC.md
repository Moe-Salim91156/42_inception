# DEV_DOC — Developer Documentation

## Prerequisites

- A Linux Virtual Machine (the project must run in a VM)
- Docker Engine installed
- Docker Compose v2 installed (`docker compose` not `docker-compose`)
- `make` installed
- `openssl` installed (for SSL cert generation, used inside the NGINX Dockerfile)

---

## Setting Up From Scratch

### 1. Clone and enter the repo
```bash
git clone git@github.com:Moe-Salim91156/42_inception.git inception
cd inception
```

### 2. Replace `yourlogin` everywhere
Do a find-and-replace for `yourlogin` across the whole project:
```bash
grep -r "yourlogin" .
```
Files to update:
- `srcs/docker-compose.yml` — the `device:` paths under volumes
- `srcs/requirements/nginx/Dockerfile` — the `-subj` CN= field
- `srcs/requirements/nginx/conf/nginx.conf` — `server_name`
- `srcs/.env` — `DOMAIN_NAME`, `WP_ADMIN_EMAIL`, `WP_USER_EMAIL`

### 3. Create secrets (these are gitignored — must be created manually)
```bash
mkdir -p secrets
echo "ChooseAStrongDbPassword!" > secrets/db_password.txt
echo "ChooseAStrongRootPassword!" > secrets/db_root_password.txt
echo "ChooseAStrongAdminPassword!" > secrets/credentials.txt
```
Password rules:
- Must be strong (mix of upper/lower/numbers/symbols)
- Must NOT contain single quotes (breaks shell scripts)

### 4. Create your `.env` file
The `.env` file is gitignored. Create it with your values:
```bash
cat > srcs/.env <<EOF
DOMAIN_NAME=yourlogin.42.fr
MYSQL_DATABASE=wordpress
MYSQL_USER=wpuser
WP_ADMIN_USER=master
WP_ADMIN_EMAIL=master@yourlogin.42.fr
WP_USER=normaluser
WP_USER_EMAIL=user@yourlogin.42.fr
WP_USER_PASS=UserPass123!
EOF
```
**Important**: `WP_ADMIN_USER` must NOT contain `admin` or `administrator` (case-insensitive).

### 5. Add your domain to `/etc/hosts`
```bash
echo "127.0.0.1 yourlogin.42.fr" | sudo tee -a /etc/hosts
```

### 6. Create the host data directories
The Makefile does this automatically with `make setup`, but you can do it manually:
```bash
mkdir -p ~/data/db ~/data/wordpress
```

---

## Building and Launching

```bash
# Full build + start (runs make setup first)
make

# Check status
make ps

# Follow logs from all containers
make logs
```

On first run, the WordPress container will:
1. Download WordPress core
2. Wait for MariaDB to be ready (retry loop up to 60 seconds)
3. Run `wp core install` to configure the site
4. Create the second user

This takes about 30–60 seconds. Watch the logs:
```bash
cd srcs && docker compose logs -f wordpress
```

---

## Managing Containers and Volumes

### Useful commands
```bash
# Enter a running container
docker exec -it nginx bash
docker exec -it wordpress bash
docker exec -it mariadb bash

# Restart a single container
docker restart wordpress

# Rebuild a single service after a Dockerfile change
cd srcs && docker compose up -d --build wordpress

# View resource usage
docker stats

# Inspect the Docker network
docker network inspect srcs_inception

# Inspect a volume
docker volume inspect srcs_db_data
docker volume inspect srcs_wordpress_files
```

### Forcing a clean WordPress reinstall
```bash
make clean
# Delete the wordpress files on the host too if needed:
sudo rm -rf ~/data/wordpress ~/data/db
make
```

---

## Where Data Lives and How It Persists

| Data | Inside container | On host machine |
|------|-----------------|-----------------|
| WordPress files | `/var/www/wordpress` | `~/data/wordpress/` |
| MariaDB database | `/var/lib/mysql` | `~/data/db/` |

Both are mounted using Docker **named volumes** with the `local` driver and `bind` option. This means:
- Stopping containers does NOT delete the data
- `make down` keeps the data
- `make clean` + deleting the host directories is required for a full wipe
- The named volumes are listed with `docker volume ls` as `srcs_db_data` and `srcs_wordpress_files`

### Why this volume setup?
The subject requires named volumes (not plain bind mounts) AND requires data to be at `/home/login/data`. Using `driver: local` with `driver_opts: type: none, o: bind` achieves both: Docker treats it as a named volume internally but the data is stored at the specified host path.

---

## Architecture Overview

```
[Browser]
    |
    | HTTPS port 443
    v
[nginx container]
    |
    | FastCGI port 9000 (Docker network: inception)
    v
[wordpress container] ──── reads/writes ──── [wordpress_files volume]
    |
    | MySQL port 3306 (Docker network: inception)
    v
[mariadb container] ──── reads/writes ──── [db_data volume]
```

### Container communication
- Containers talk to each other using **service names** as hostnames (Docker internal DNS)
- `wordpress` reaches MariaDB at `mariadb:3306`
- `nginx` reaches PHP-FPM at `wordpress:9000`
- No container is reachable from the host except nginx on port 443

### Startup order
`depends_on` in docker-compose ensures:
1. `mariadb` starts first
2. `wordpress` starts after mariadb
3. `nginx` starts after wordpress

But `depends_on` only waits for the container to **start**, not for the service inside to be **ready**. That is why `wp-setup.sh` has a retry loop waiting for MariaDB to accept connections before proceeding.
