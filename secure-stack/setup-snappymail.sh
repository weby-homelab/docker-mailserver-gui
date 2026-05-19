#!/usr/bin/env bash

set -euo pipefail

# Check if .env exists
if [[ ! -f .env ]]; then
    echo "❌ Error: .env file not found. Run ./setup-gui.sh first."
    exit 1
fi

# Load variables from .env
# shellcheck disable=SC1091
source .env

echo "⚙️  Configuring SnappyMail domains for ${WEBMAIL_HOSTNAME}..."

# Wait for SnappyMail container to be ready and directory to exist
echo "⏳ Waiting for SnappyMail directory initialization..."
MAX_RETRIES=10
COUNT=0
while [[ ! -d "./snappymail-data/_data_/_default_/domains" ]]; do
    sleep 5
    COUNT=$((COUNT + 1))
    if [[ ${COUNT} -ge ${MAX_RETRIES} ]]; then
        echo "❌ Error: SnappyMail data directory not found after waiting. Ensure stack is running."
        exit 1
    fi
done

# Create the JSON configuration for the domain
cat <<EOF > "./snappymail-data/_data_/_default_/domains/${WEBMAIL_HOSTNAME}.json"
{
    "IMAP": {
        "host": "dms-core",
        "port": 143,
        "type": 0,
        "ssl": { "verify_peer": false, "verify_peer_name": false, "allow_self_signed": true }
    },
    "SMTP": {
        "host": "dms-core",
        "port": 587,
        "type": 0,
        "useAuth": true,
        "ssl": { "verify_peer": false, "verify_peer_name": false, "allow_self_signed": true }
    }
}
EOF

# Ensure same config exists for default.json
cp "./snappymail-data/_data_/_default_/domains/${WEBMAIL_HOSTNAME}.json" "./snappymail-data/_data_/_default_/domains/default.json"

# Fix permissions
docker exec dms-snappymail chown -R www-data:www-data /var/lib/snappymail/_data_/_default_/domains/
docker exec dms-snappymail chmod 600 /var/lib/snappymail/_data_/_default_/domains/*.json

echo "✅ SnappyMail configuration applied!"
echo ""
echo "🔐 YOUR ADMIN CREDENTIALS:"
echo "-----------------------------------"
echo "Login: admin"
echo "Passphrase: $(docker exec dms-snappymail cat /var/lib/snappymail/_data_/_default_/admin_password.txt)"
echo "-----------------------------------"
echo "Visit: https://${WEBMAIL_HOSTNAME}/?admin"
