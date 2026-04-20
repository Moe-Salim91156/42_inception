#!/bin/bash
set -e

DB_PASS=$(cat /run/secrets/db_password)
WP_ADMIN_PASS=$(cat /run/secrets/credentials)
WP_PATH=/var/www/wordpress
cd ${WP_PATH}
echo ">>> Waiting for MariaDB..."
COUNT=0
until nc -z mariadb 3306 2>/dev/null; do
    COUNT=$((COUNT + 1))
    [ $COUNT -ge 30 ] && echo "ERROR: MariaDB timeout" && exit 1
    echo "    Waiting... ($COUNT/30)"
    sleep 2
done
echo ">>> MariaDB ready!"
if [ ! -f "${WP_PATH}/wp-config.php" ]; then
    echo ">>> Installing WordPress..."

    [ ! -f "${WP_PATH}/index.php" ] && wp core download --allow-root --quiet

    wp config create --allow-root \
        --dbname="${MYSQL_DATABASE}" \
        --dbuser="${MYSQL_USER}" \
        --dbpass="${DB_PASS}" \
        --dbhost=mariadb:3306 \
        --dbprefix=wp_

    wp core install --allow-root \
        --url="https://${DOMAIN_NAME}" \
        --title="Inception" \
        --admin_user="${WP_ADMIN_USER}" \
        --admin_password="${WP_ADMIN_PASS}" \
        --admin_email="${WP_ADMIN_EMAIL}" \
        --skip-email

    wp user create --allow-root \
        "${WP_USER}" "${WP_USER_EMAIL}" \
        --role=author \
        --user_pass="${WP_USER_PASS}"

    echo ">>> Done! Admin: ${WP_ADMIN_USER}"
else
    echo ">>> Already installed, skipping."
fi

chown -R www-data:www-data ${WP_PATH}
exec php-fpm8.2 -F
