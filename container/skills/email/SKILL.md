---
name: email
description: Read, search, and send email using a local Maildir cache. Use for any email-related task — checking inbox, searching messages, reading threads, composing replies, or sending new emails. Sync runs automatically but can be triggered manually.
allowed-tools: Bash(mbsync:*), Bash(himalaya:*), Bash(notmuch:*)
---

# Email (Maildir + himalaya + notmuch)

**This is YOUR mailbox.** The email address in `$EMAIL_USER` belongs to you (the agent), not the user. You can use it to:
- Send emails on your own behalf
- Receive emails and act on them
- Subscribe to notifications, confirmations, etc.
- Correspond with people when asked

**IMPORTANT: Never send or reply to emails unless the user has reasonably directly asked you to.** Reading and searching mail is always fine, but composing/sending/replying requires a clear request from the user. Don't send emails based on your own initiative or judgment — wait to be asked.

Your email address is available as the environment variable `$EMAIL_USER`. Use it in From headers and whenever you need to tell someone how to reach you.

Email is available via a local Maildir cache at `/data/mail/Maildir`, synced from IMAP by mbsync. Reads and searches are instant (local disk). Sends go via SMTP.

## Sync mail (fetch new messages from server)

```bash
mbsync nanoclaw              # Incremental sync (fast — only new/changed)
```

Always sync before reading if freshness matters.

## Read mail with himalaya

```bash
himalaya list                         # List inbox (default: 10 messages)
himalaya list -s 50                   # List 50 messages
himalaya list -f "Sent"               # List sent folder
himalaya list -f "INBOX"              # Explicit inbox
himalaya read <id>                    # Read message by ID
himalaya read <id> --header "From"    # Show specific header
himalaya reply <id>                   # Reply to message (opens editor — use send instead)
himalaya attachments <id>             # Download attachments
```

## Search mail with notmuch

notmuch provides fast full-text search across all synced mail.

```bash
notmuch new                           # Index new messages after sync
notmuch search "from:alice@example.com"
notmuch search "subject:invoice"
notmuch search "date:2024-01-01..today AND from:bob"
notmuch search "tag:unread"
notmuch search "to:me AND subject:urgent"
notmuch show --format=text <thread-id>   # Read full thread
```

Always run `notmuch new` after `mbsync nanoclaw` to index new messages.

## Send mail with himalaya

```bash
# Send a new message
himalaya send <<EOF
From: $EMAIL_USER
To: recipient@example.com
Subject: Hello

Message body here.
EOF

# Send with attachment
himalaya send --attachment /path/to/file.pdf <<EOF
From: $EMAIL_USER
To: recipient@example.com
Subject: Report attached

Please find the report attached.
EOF
```

## Common workflows

### Check for new mail
```bash
mbsync nanoclaw
notmuch new
notmuch search "tag:unread" | head -20
```

### Find and read a specific message
```bash
notmuch search "from:alice subject:meeting"
notmuch show --format=text <thread-id>
```

### Reply to a message
Read the original with `himalaya read <id>` or `notmuch show`, then compose a reply with `himalaya send`, including the appropriate `In-Reply-To` and `References` headers from the original.

## Folder names

Common IMAP folder names (may vary by provider):
- `INBOX` — main inbox
- `Sent` or `Sent Messages` — sent mail
- `Drafts` — drafts
- `Trash` — deleted messages
- `Archive` — archived messages

List available folders: `himalaya folder list`

## Notes

- Mail is stored at `/data/mail/Maildir` (persistent across container restarts)
- Config files are generated automatically from environment variables at startup
- If email is not configured (no `EMAIL_USER` env var), the tools will not be available
