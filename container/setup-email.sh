#!/bin/bash
# Generate email tool configs from environment variables at container startup.
# Requires: IMAP_HOST, IMAP_PORT, SMTP_HOST, SMTP_PORT, EMAIL_USER, EMAIL_PASS
# Mail is stored in /data/mail/Maildir (persistent volume).

set -e

# Skip if email is not configured
if [ -z "$EMAIL_USER" ] || [ -z "$EMAIL_PASS" ]; then
  exit 0
fi

MAIL_DIR="/data/mail"
MAILDIR_PATH="${MAIL_DIR}/Maildir"
NOTMUCH_DB="${MAIL_DIR}/notmuch"

mkdir -p "$MAILDIR_PATH" "$NOTMUCH_DB"

# --- mbsync (isync) config ---
cat > "$HOME/.mbsyncrc" <<EOF
IMAPAccount nanoclaw
Host ${IMAP_HOST}
Port ${IMAP_PORT}
User ${EMAIL_USER}
Pass ${EMAIL_PASS}
SSLType IMAPS
CertificateFile /etc/ssl/certs/ca-certificates.crt

IMAPStore nanoclaw-remote
Account nanoclaw

MaildirStore nanoclaw-local
Subfolders Verbatim
Path ${MAILDIR_PATH}/
Inbox ${MAILDIR_PATH}/INBOX

Channel nanoclaw
Far :nanoclaw-remote:
Near :nanoclaw-local:
Patterns *
Create Both
Expunge Both
SyncState *
EOF
chmod 600 "$HOME/.mbsyncrc"

# --- notmuch config (default location so no env var needed) ---
cat > "$HOME/.notmuch-config" <<EOF
[database]
path=${MAILDIR_PATH}

[user]
name=NanoClaw
primary_email=${EMAIL_USER}

[new]
tags=unread;inbox;
ignore=

[search]
exclude_tags=deleted;spam;

[maildir]
synchronize_flags=true
EOF

# Initialise notmuch DB if it doesn't exist yet
if [ ! -d "${MAILDIR_PATH}/.notmuch" ]; then
  notmuch new 2>/dev/null || true
fi

# --- himalaya config (uses local Maildir for reads, SMTP for sends) ---
mkdir -p "$HOME/.config/himalaya"
cat > "$HOME/.config/himalaya/config.toml" <<EOF
[accounts.default]
default = true
email = "${EMAIL_USER}"
display-name = "NanoClaw"

# Read from local Maildir (fast, cached by mbsync)
backend.type = "maildir"
backend.root-dir = "${MAILDIR_PATH}"

# Send via SMTP
message.send.backend.type = "smtp"
message.send.backend.host = "${SMTP_HOST}"
message.send.backend.port = ${SMTP_PORT}
message.send.backend.login = "${EMAIL_USER}"
message.send.backend.auth.type = "password"
message.send.backend.auth.raw = "${EMAIL_PASS}"
message.send.backend.encryption.type = "tls"
EOF
chmod 600 "$HOME/.config/himalaya/config.toml"
