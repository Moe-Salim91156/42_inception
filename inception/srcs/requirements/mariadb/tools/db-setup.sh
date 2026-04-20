#!/bin/bash
set -e

DB_PASS=$(cat /run/secrets/db_password)
DB_ROOT_PASS=$(cat /run/secrets/db_root_password)

if [ ! -d "/var/lib/mysql/${MYSQL_DATABASE}" ]; then
    echo ">>> First boot: initializing MariaDB..."

    mysql_install_db --user=mysql --datadir=/var/lib/mysql > /dev/null

    mysqld_safe --skip-networking --skip-grant-tables &
    TEMP_PID=$!

    sleep 5

    mysql -u root <<EOF
FLUSH PRIVILEGES;
ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASS}';
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${DB_PASS}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
FLUSH PRIVILEGES;
EOF

    echo ">>> Database initialized. Shutting down temp instance..."

    mysqladmin -u root -p"${DB_ROOT_PASS}" shutdown || true
    wait $TEMP_PID 2>/dev/null || true

    echo ">>> MariaDB ready."
else
    echo ">>> Database already exists, skipping init."
fi

exec mysqld_safe --user=mysql
