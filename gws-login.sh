#!/bin/bash
# Run gws auth login with credentials stored in data/gws-config/
# Uses file-based encryption (no OS keyring) so containers can read them.
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
GOOGLE_WORKSPACE_CLI_CONFIG_DIR="$SCRIPT_DIR/data/gws-config" \
GOOGLE_WORKSPACE_CLI_KEYRING_BACKEND=file \
npx @googleworkspace/cli auth login --scopes \
  "https://www.googleapis.com/auth/drive,https://www.googleapis.com/auth/spreadsheets,https://www.googleapis.com/auth/gmail.readonly,https://www.googleapis.com/auth/calendar,https://www.googleapis.com/auth/documents,https://www.googleapis.com/auth/presentations,https://www.googleapis.com/auth/tasks,openid,https://www.googleapis.com/auth/userinfo.email"
