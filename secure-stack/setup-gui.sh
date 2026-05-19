#!/usr/bin/env bash

set -euo pipefail

echo "🛡️  Initializing Full Stack Secure Deployment..."

# 1. Create necessary directories to avoid permission issues caused by Docker running as root
mkdir -p ./dms/mail-data
mkdir -p ./dms/mail-state
mkdir -p ./dms/mail-logs
mkdir -p ./dms/config
mkdir -p ./dms/ssl
mkdir -p ./traefik-data
mkdir -p ./snappymail-data

# 2. Secure traefik acme.json (must have 600 permissions)
touch ./traefik-data/acme.json
chmod 600 ./traefik-data/acme.json

# 3. Create .env from example if it doesn't exist
if [[ ! -f .env ]]; then
    cp .env.example .env
    echo "✅ Created .env file. Please edit it to match your domains before starting."
else
    echo "⚠️  .env file already exists. Skipping creation."
fi

echo ""
echo "✅ Initialization complete!"
echo ""
echo "🚀 Next steps:"
echo "1. Edit the .env file with your actual domains (MAIL_HOSTNAME, WEBMAIL_HOSTNAME) and ACME_EMAIL."
echo "2. Ensure your DNS A records for both domains point to this server."
echo "3. Run 'docker compose up -d' to start the secure stack."
echo "4. Wait ~30 seconds for certificates to generate, then run:"
echo "   ./setup-snappymail.sh"
echo "5. Create your first email account:"
echo "   docker exec -ti dms-core setup email add user@yourdomain.com <password>"
echo ""
echo "🔒 SnappyMail Webmail will be available at https://\$WEBMAIL_HOSTNAME"
echo "   (Admin panel: https://\$WEBMAIL_HOSTNAME/?admin)"
echo "   The secure admin password will be printed when you run setup-snappymail.sh"
