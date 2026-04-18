# ⚠️  Penultimate stable Debian — NOT 'latest'
FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y \
    nginx \
    openssl \
    && rm -rf /var/lib/apt/lists/*

# ──────────────────────────────────────────────
# SSL Certificate — self-signed for local dev
# ⚠️  The subject requires TLSv1.2 or TLSv1.3 ONLY
#     No TLSv1.0, no TLSv1.1, no plain HTTP
# ⚠️  Replace 'yourlogin' in the CN field with your actual 42 login
# ──────────────────────────────────────────────
RUN mkdir -p /etc/nginx/ssl && \
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout /etc/nginx/ssl/server.key \
        -out /etc/nginx/ssl/server.crt \
        -subj "/C=FR/ST=IDF/L=Paris/O=42/OU=student/CN=msalim.42.fr"
#              ⚠️ Change 'yourlogin' above ↑

# Copy NGINX site configuration
COPY conf/nginx.conf /etc/nginx/sites-available/default

# ⚠️  Port 443 ONLY — never expose 80
EXPOSE 443

# ⚠️  'daemon off' keeps nginx in foreground as PID 1
#     Without this nginx would daemonize and the container would exit
CMD ["nginx", "-g", "daemon off;"]
