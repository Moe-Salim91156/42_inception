#!/bin/bash
set -e

DB_PASS=$(cat /run/secrets/db_password)
WP_DIR=/var/www/html

mkdir -p $WP_DIR

if [ ! -f "$WP_DIR/wp-config.php" ]; then
    wp core download --path=$WP_DIR --allow-root

    wp config create \
        --path=$WP_DIR \
        --dbname=${MYSQL_DATABASE} \
        --dbuser=${MYSQL_USER} \
        --dbpass=${DB_PASS} \
        --dbhost=mariadb:3306 \
        --allow-root

    wp core install \
        --path=$WP_DIR \
        --url=https://${DOMAIN_NAME} \
        --title="Inception" \
        --admin_user=${WP_ADMIN_USER} \
        --admin_email=${WP_ADMIN_EMAIL} \
        --admin_password=$(cat /run/secrets/credentials) \
        --skip-email \
        --allow-root
fi

exec php-fpm8.2 -F
