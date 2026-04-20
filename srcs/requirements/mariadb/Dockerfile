FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y \
    mariadb-server \
    && rm -rf /var/lib/apt/lists/*

COPY conf/my.cnf /etc/mysql/mariadb.conf.d/50-server.cnf

COPY tools/db-setup.sh /usr/local/bin/db-setup.sh
RUN chmod +x /usr/local/bin/db-setup.sh

EXPOSE 3306

ENTRYPOINT ["db-setup.sh"]
