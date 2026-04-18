#!/bin/bash
# ⚠️  set -e makes the script exit immediately if any command fails
#     This is critical — don't remove it
set -e

# ──────────────────────────────────────────────
# Read passwords from Docker secrets
# ⚠️  Secrets are mounted at /run/secrets/<name> inside the container
# ⚠️  Never echo these to logs in production
# ──────────────────────────────────────────────
DB_PASS=$(cat /run/secrets/db_password)
DB_ROOT_PASS=$(cat /run/secrets/db_root_password)

# ──────────────────────────────────────────────
# Only initialize the database on FIRST boot
# Without this check, it would re-initialize every restart and wipe data
# ──────────────────────────────────────────────
if [ ! -d "/var/lib/mysql/${MYSQL_DATABASE}" ]; then
    echo ">>> First boot: initializing MariaDB..."

    # Initialize the data directory
    mysql_install_db --user=mysql --datadir=/var/lib/mysql > /dev/null

    # Start MariaDB temporarily WITHOUT networking for secure setup
    mysqld_safe --skip-networking --skip-grant-tables &
    TEMP_PID=$!

    # ⚠️  Wait for the temporary instance to be ready
    #     This sleep is necessary — do NOT remove it
    sleep 5

    # Configure users and database
    mysql -u root <<EOF
FLUSH PRIVILEGES;
ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASS}';
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${DB_PASS}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
FLUSH PRIVILEGES;
EOF

    echo ">>> Database initialized. Shutting down temp instance..."

    # Cleanly shut down the temporary instance
    mysqladmin -u root -p"${DB_ROOT_PASS}" shutdown || true
    wait $TEMP_PID 2>/dev/null || true

    echo ">>> MariaDB ready."
else
    echo ">>> Database already exists, skipping init."
fi

# ──────────────────────────────────────────────
# ⚠️  CRITICAL: Use 'exec' so mysqld_safe becomes PID 1
#     Without exec, the shell is PID 1 and signals won't reach MariaDB
#     This is required for proper container shutdown and restart behavior
# ──────────────────────────────────────────────
exec mysqld_safe --user=mysql
