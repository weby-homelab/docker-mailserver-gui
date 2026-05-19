#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${SCRIPT_DIR}/secure-stack"

echo "Adding dummy Traefik labels to dms-core to force certificate generation..."
# shellcheck disable=SC2016
sed -i '/restart: always/a \    labels:\n      - "traefik.enable=true"\n      - "traefik.http.routers.mail.rule=Host(\`${MAIL_HOSTNAME}\`)"\n      - "traefik.http.routers.mail.entrypoints=websecure"\n      - "traefik.http.routers.mail.tls.certresolver=letsencrypt"\n      - "traefik.http.services.mail.loadbalancer.server.port=80"' docker-compose.yml

echo "Adding cert-dumper service..."
cat << 'EOF' >> docker-compose.yml

  cert-dumper:
    image: ldez/traefik-certs-dumper:latest
    container_name: dms-cert-dumper
    command: file --version v2 --watch --source /traefik/acme.json --dest /ssl --post-hook "docker exec dms-core postfix reload && docker exec dms-core dovecot reload"
    volumes:
      - ./traefik-data:/traefik:ro
      - ./dms/ssl:/ssl
      - /var/run/docker.sock:/var/run/docker.sock:ro
    restart: unless-stopped
    networks:
      - secure-mail-network
EOF

echo "Configuring dms-core to use manual SSL certificates..."
# shellcheck disable=SC2016
sed -i '/ENABLE_POSTGREY=0/a \      - SSL_TYPE=manual\n      - SSL_CERT_PATH=/ssl/certs/${MAIL_HOSTNAME}.crt\n      - SSL_KEY_PATH=/ssl/private/${MAIL_HOSTNAME}.key' docker-compose.yml
sed -i '/- .\/dms\/config:\/tmp\/docker-mailserver/a \      - .\/dms\/ssl:\/ssl:ro' docker-compose.yml

echo "Restarting stack..."
docker compose pull cert-dumper
docker compose up -d

echo "Waiting for certificates to be generated and dumped..."
sleep 25
docker exec dms-core postfix reload || true
docker exec dms-core dovecot reload || true

echo "Checking dumped certificates..."
ls -la ./dms/ssl/certs/ || true
