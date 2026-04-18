# ⚠️  Use penultimate stable version of Debian or Alpine — NOT 'latest'
#     bookworm = Debian 12 (current stable as of subject v5.2)
#     If Debian 13 releases, switch base to: debian:bookworm-slim (still fine)
FROM debian:bookworm-slim

# ⚠️  No passwords here! All credentials come from Docker secrets at runtime
RUN apt-get update && apt-get install -y \
    mariadb-server \
    && rm -rf /var/lib/apt/lists/*   # Always clean apt cache to keep image small

# Copy custom MariaDB config (allows remote connections)
COPY conf/my.cnf /etc/mysql/mariadb.conf.d/50-server.cnf

# Copy and prepare the setup script
COPY tools/db-setup.sh /usr/local/bin/db-setup.sh
RUN chmod +x /usr/local/bin/db-setup.sh

# MariaDB default port
EXPOSE 3306

# ⚠️  ENTRYPOINT must NOT use: tail -f, bash, sleep infinity, while true
#     The script must exec the real daemon as PID 1 at the end
ENTRYPOINT ["db-setup.sh"]
