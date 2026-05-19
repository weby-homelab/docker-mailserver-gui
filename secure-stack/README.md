# Docker Mailserver GUI - Secure Full Stack Deployment

This directory contains a robust, secure-by-default Docker Compose stack that deploys `docker-mailserver` alongside a modern Webmail interface (SnappyMail) and an automatic HTTPS reverse proxy (Traefik).

## Architecture & Security Model (Zero Trust)

We adhere strictly to the "Zero Fallback Credentials" and container isolation mandates. Adding a GUI to a mail server can drastically increase the attack surface. To solve this safely:

1. **Isolation:** The core `docker-mailserver` remains completely unmodified and isolated. It handles raw SMTP/IMAP traffic.
2. **Reverse Proxy (Traefik):** Handles all HTTP/HTTPS traffic. It automatically provisions Let's Encrypt certificates and enforces HTTPS.
3. **Webmail Sidecar (SnappyMail):** A lightweight, DB-less PHP client. It is **NOT** exposed directly to the internet. It sits behind Traefik and communicates with the mail server internally via the closed Docker network on port 143/587.

## Getting Started

1. **Initialize the environment:**
    ```bash
    cd secure-stack
    chmod +x setup-gui.sh
    ./setup-gui.sh
    ```

2. **Configure Domains:**
    Edit the newly created `.env` file to match your infrastructure:
    ```env
    MAIL_HOSTNAME=mail.yourdomain.com
    WEBMAIL_HOSTNAME=webmail.yourdomain.com
    ACME_EMAIL=admin@yourdomain.com
    ```

3. **DNS Setup:**
    Ensure both `mail.yourdomain.com` and `webmail.yourdomain.com` point to your server's public IP address.

4. **Start the Stack:**
    ```bash
    docker compose up -d
    ```

5. **Create your first mailbox:**
    ```bash
    docker exec -ti dms-core setup email add user@yourdomain.com secret-password
    ```

6. **Access Webmail:**
    Go to `https://webmail.yourdomain.com`. 
    *Note: SnappyMail has its own admin panel available at `/?admin`. The default password is `12345` (you MUST change this immediately upon first login).*

## Notes on ActiveSync (EAS)

Adding EAS natively into the DMS container is an anti-pattern as it requires a heavy PHP/DB stack (like Z-Push or SOGo). If you must support legacy Outlook clients via EAS, you should deploy a dedicated SOGo container as an additional sidecar in this `docker-compose.yml`, routing it similarly to SnappyMail.

