FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y \
    netcat-openbsd \
    php8.2-fpm \
    php8.2-mysql \
    php8.2-curl \
    php8.2-gd \
    php8.2-mbstring \
    php8.2-xml \
    php8.2-zip \
    php8.2-intl \
    wget \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Install WP-CLI — command line tool to configure WordPress automatically
# ⚠️  This is the cleanest way to install WP without manual steps
RUN wget -q https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp

# ⚠️  CRITICAL: Configure php-fpm to listen on TCP 9000, not a Unix socket
#     NGINX is in a DIFFERENT container — it cannot access a Unix socket
COPY conf/www.conf /etc/php/8.2/fpm/pool.d/www.conf

RUN mkdir -p /var/www/wordpress && chown -R www-data:www-data /var/www/wordpress

COPY tools/wp-setup.sh /usr/local/bin/wp-setup.sh
RUN chmod +x /usr/local/bin/wp-setup.sh

EXPOSE 9000

# ⚠️  No tail -f, no bash, no sleep infinity
#     wp-setup.sh must end with: exec php-fpmX.X -F
ENTRYPOINT ["wp-setup.sh"]
