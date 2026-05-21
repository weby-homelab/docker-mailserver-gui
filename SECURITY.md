# Security Policy

## Supported Versions

The following versions of **Docker Mailserver GUI** are currently supported with security updates:

| Version | Supported          |
| ------- | ------------------ |
| 0.9.x   | :white_check_mark: |
| < 0.9.0 | :x:                |

## Our Security Philosophy (Zero Trust)

This project is built on the principle of **Zero Trust Architecture**. We believe that adding a GUI to a mail server should not compromise its core integrity. 

1. **Isolation:** The mail server engine (`dms-core`) is strictly isolated from the web interface. It only communicates via internal Docker networks.
2. **Zero Fallback Credentials:** We have audited and removed all hardcoded default credentials from the core images (including Supervisor UNIX sockets).
3. **Automated Encryption:** All external traffic is forced through Traefik with mandatory TLS (Let's Encrypt). Plain-text authentication is disabled for all public-facing ports.
4. **Sidecar Security:** We use sidecar containers (like `cert-dumper`) to handle sensitive tasks like certificate extraction, ensuring the core container doesn't need excessive privileges.

## Reporting a Vulnerability

If you discover a security vulnerability within this project, please **do not open a public issue**. Instead, help us protect the community by reporting it privately.

Please send your report to: **contact@srvrs.top**

In your report, please include:
- A description of the vulnerability.
- Steps to reproduce the issue (PoC).
- Potential impact.

We aim to acknowledge all reports within 48 hours and provide a fix or mitigation strategy as soon as possible.

## Security Audit Status

- **Static Analysis:** The codebase is regularly scanned with `hadolint`, `shellcheck`, and `eclint` to ensure shell scripts and Dockerfiles adhere to security guidelines.
- **Dependency Scanning:** We use `OSV-Scanner`, GitHub Dependabot, and vulnerability-scan actions to monitor for CVEs in base images and packages.
- **Manual Audit:** The `supervisord.conf` process manager and `setup-gui.sh` configuration scripts have been manually audited for privilege escalation paths and credential leaks as of the `v0.9.6` release in May 2026.
