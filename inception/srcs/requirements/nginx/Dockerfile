FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y \
    nginx \
    openssl \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /etc/nginx/ssl && \
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout /etc/nginx/ssl/server.key \
        -out /etc/nginx/ssl/server.crt \
        -subj "/C=FR/ST=IDF/L=Paris/O=42/OU=student/CN=msalim.42.fr"

COPY conf/nginx.conf /etc/nginx/sites-available/default

EXPOSE 443

# ⚠️  'daemon off' keeps nginx in foreground as PID 1
CMD ["nginx", "-g", "daemon off;"]
