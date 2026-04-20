*This project has been created as part of the 42 curriculum by yourlogin.*

# Inception

## Description

Inception is a system administration project from the 42 curriculum. The goal is to set up a small web infrastructure using Docker Compose inside a virtual machine. Each service runs in its own dedicated container built from scratch using custom Dockerfiles.

The stack consists of:
- **NGINX** — the sole entry point, handles HTTPS (TLSv1.2/1.3) on port 443
- **WordPress + PHP-FPM** — the web application
- **MariaDB** — the database backend

### Design Choices

#### Virtual Machines vs Docker
Virtual machines emulate an entire operating system including the kernel, making them heavier and slower to start. Docker containers share the host kernel and package only the application and its dependencies, making them much lighter and faster. VMs are better for full OS isolation; Docker is better for reproducible, portable service deployments.

#### Secrets vs Environment Variables
Environment variables (`.env`) are suitable for non-sensitive config like domain names or usernames. Secrets (Docker secrets, stored as files in `/run/secrets/`) are used for sensitive data like passwords — they are not exposed in the container's environment and are harder to leak accidentally. This project uses Docker secrets for all passwords and `.env` for everything else.

#### Docker Network vs Host Network
A Docker bridge network creates an isolated virtual network between containers. Host network mode shares the host's network stack directly, removing isolation and bypassing Docker's internal DNS. This project uses a custom bridge network (`inception`) so containers communicate using service names (e.g., `mariadb`, `wordpress`) and are not directly exposed to the host network.

#### Docker Volumes vs Bind Mounts
Bind mounts directly link a host path to a container path — simple but fragile (depends on host directory structure). Named volumes are managed by Docker and are more portable. This project uses named volumes with a `local` driver bound to `/home/yourlogin/data/` on the host, satisfying both the named volume requirement and the specific host path requirement from the subject.

---

## Instructions

### Prerequisites
- A Linux Virtual Machine with Docker and Docker Compose installed
- Your 42 login replacing `yourlogin` throughout the project

### Setup

1. Clone the repository:
```bash
git clone git@github.com:Moe-Salim91156/42_inception.git inception
cd inception
```

2. Replace `yourlogin` with your actual 42 login in , example my login is : `msalim`:
   - `srcs/docker-compose.yml` (volumes section)
   - `srcs/requirements/nginx/Dockerfile` (CN field in openssl command)
   - `srcs/requirements/nginx/conf/nginx.conf` (server_name)
   - `srcs/.env` (DOMAIN_NAME, emails)

3. Create the secrets files (these are gitignored — create them manually):
```bash
mkdir -p secrets
echo "your_db_password" > secrets/db_password.txt
echo "your_db_root_password" > secrets/db_root_password.txt
echo "your_wp_admin_password" > secrets/credentials.txt
```

4. Create the `.env` file (gitignored — create it manually):
```bash
cp srcs/.env.example srcs/.env
# then edit srcs/.env with your values
```

5. Add your domain to `/etc/hosts`:
```bash
echo "127.0.0.1 yourlogin.42.fr" | sudo tee -a /etc/hosts
```

6. Build and start:
```bash
make
```

7. Visit `https://yourlogin.42.fr` in your browser (accept the self-signed cert warning).

### Stopping
```bash
make down
```

### Full reset
```bash
make clean
```

---

## Resources

### Docker & Infrastructure
- [Docker official documentation](https://docs.docker.com/)
- [Docker Compose reference](https://docs.docker.com/compose/compose-file/)
- [Docker secrets documentation](https://docs.docker.com/engine/swarm/secrets/)
- [NGINX FastCGI with PHP-FPM](https://nginx.org/en/docs/http/ngx_http_fastcgi_module.html)
- [PHP-FPM configuration](https://www.php.net/manual/en/install.fpm.configuration.php)
- [MariaDB Docker setup guide](https://mariadb.com/kb/en/mariadb-docker-environment-variables/)
- [WP-CLI documentation](https://wp-cli.org/)
- [Understanding PID 1 in containers](https://cloud.google.com/architecture/best-practices-for-building-containers#signal-handling)
- [Dockerfile best practices](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/)
- [TLS protocol versions](https://nginx.org/en/docs/http/ngx_http_ssl_module.html#ssl_protocols)

### AI Usage
AI (Claude) was used in this project for:
- **Initial architecture planning**: understanding the connection flow between NGINX, PHP-FPM, and MariaDB across containers
- **Dockerfile drafting**: generating a base structure for each service's Dockerfile which was then reviewed and tested manually
- **Shell script logic**: drafting the MariaDB initialization and WordPress setup scripts, particularly the MariaDB readiness wait loop
- **Documentation**: generating the first draft of README, USER_DOC, and DEV_DOC which were then reviewed and corrected

All AI-generated content was reviewed, tested, and understood before being included in the project.
