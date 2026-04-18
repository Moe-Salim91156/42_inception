# ✅ Inception Setup Checklist
## Read this before touching anything else

---

## Step 1 — Search and replace YOUR LOGIN
Run this to find every place you need to substitute your login:
```bash
grep -r "yourlogin" .
```
Replace in ALL these files:
- [ ] `srcs/docker-compose.yml` → volumes → `device:` paths (×2)
- [ ] `srcs/requirements/nginx/Dockerfile` → `-subj "... CN=yourlogin.42.fr"`
- [ ] `srcs/requirements/nginx/conf/nginx.conf` → `server_name`
- [ ] `srcs/.env` → `DOMAIN_NAME`, both email fields
- [ ] `README.md` → first line (your login)

---

## Step 2 — Create secrets (NEVER commit these)
```bash
mkdir -p secrets
echo "StrongDbPass123!"     > secrets/db_password.txt
echo "StrongRootPass456!"   > secrets/db_root_password.txt
echo "StrongAdminPass789!"  > secrets/credentials.txt
```
⚠️ No single quotes in passwords — they break shell scripts

---

## Step 3 — Set your admin username in .env
Open `srcs/.env` and set `WP_ADMIN_USER` to something that does NOT contain:
- ❌ admin
- ❌ Admin
- ❌ administrator
- ❌ Administrator
- ❌ admin-anything

✅ OK examples: `master`, `webmaster`, `superuser`, `wpmaster`, `johndoe`

---

## Step 4 — Add domain to /etc/hosts on your VM
```bash
echo "127.0.0.1 yourlogin.42.fr" | sudo tee -a /etc/hosts
```

---

## Step 5 — Build and run
```bash
make
```
Then wait ~60 seconds and visit `https://yourlogin.42.fr`

---

## Step 6 — Verify everything before defense

```bash
# All 3 containers should show 'Up'
cd srcs && docker compose ps

# Site loads
curl -k https://yourlogin.42.fr | head -20

# Two users exist in WordPress
docker exec -it wordpress wp user list --allow-root

# Volumes are at the right place
ls ~/data/db
ls ~/data/wordpress

# No secrets in git history
git log --all --full-history -- secrets/
git log --all --full-history -- srcs/.env
```

---

## Common problems and fixes

| Problem | Fix |
|---------|-----|
| `wordpress` container keeps restarting | MariaDB not ready → check logs: `docker compose logs wordpress` |
| `502 Bad Gateway` from nginx | PHP-FPM not listening on TCP — check `www.conf` has `listen = 0.0.0.0:9000` |
| Can't reach `yourlogin.42.fr` | Check `/etc/hosts` has the entry, and that port 443 is exposed |
| Database already exists error | Run `make clean` then `make` to start fresh |
| `wp: command not found` | WP-CLI not installed — check WordPress Dockerfile |
| Volume device path error | Run `mkdir -p ~/data/db ~/data/wordpress` first, OR just `make` which calls `make setup` |
