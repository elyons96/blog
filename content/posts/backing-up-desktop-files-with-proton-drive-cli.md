---
title: "Backing Up Desktop Files with Proton Drive CLI and Cron"
date: 2026-10-26
tags:
  - "Tech/DevOps"
  - "Privacy"
aliases: []
draft: false
---

## Why Not the Desktop App?

Proton Drive offers a desktop sync application that keeps files in real-time sync between your machine and the cloud. It works well for many people, but I prefer the CLI approach for one reason: **control**.

With the CLI, I decide exactly *what* gets backed up, *when*, and *how*. Combined with cron jobs, this gives me predictable, auditable backups without background processes eating resources or silently overwriting things I didn't intend.

## Installation

**Official Documentation:** https://proton.me/support/drive-cli

The Proton Drive CLI is a single binary. On Fedora Linux (x86_64):

```bash
curl -L -o /tmp/proton-drive https://proton.me/download/drive/cli/0.9.0/linux-x64/proton-drive
chmod +x /tmp/proton-drive
sudo mv /tmp/proton-drive /usr/local/bin/proton-drive
```

Verify the checksum before running:

```bash
sha512sum /usr/local/bin/proton-drive
# Expected: 3533025ba69ae112b64e3e01fbcc1ad0688136a4043f6cf6a72886967d85fdcd9ec235479c2e113171614be5225bfba93427509a05ca5aa6071d924fa7e91ca8
```

## Authentication

```bash
proton-drive auth login
```

This opens a browser for you to authorize with your Proton account. Keep the terminal open until authentication completes.

## Creating Your Backup Structure

```bash
# Create a dedicated backup folder
proton-drive filesystem create-folder /my-files FWAI01
```

I use `FWAI01` as my backup root — it's the hostname of this machine, so any future backups from other machines will have their own distinct folders.

## Uploading Files

The key flags for automated backups:

- **`-f skip`** — Skip files that already exist on Proton Drive (don't overwrite)
- **`-d merge`** — Merge folder contents instead of replacing entire folders

```bash
# Upload your Documents folder
proton-drive filesystem upload -f skip -d merge /home/elyons/Documents /my-files/FWAI01

# Upload a blog or project directory
proton-drive filesystem upload -f skip -d merge /home/elyons/Blog /my-files/FWAI01
```

The CLI reports a transfer summary: `Uploaded: X items (Y MiB)`. If nothing changed, it uploads zero files. This makes repeated runs cheap and fast.

### Other Conflict Strategies

| Flag | Behavior |
|------|----------|
| `-f replace` | Trash remote file, upload local copy |
| `-f rename` | Add unique suffix to name |
| `-f create-new-revision` | Create new version of existing file |
| `-d merge` | Merge folder contents (recommended for backups) |

## Automating with Cron

Set up daily cron jobs for hands-off backups:

```bash
# Documents backup at 1 AM
0 1 * * * proton-drive filesystem upload -f skip -d merge /home/elyons/Documents /my-files/FWAI01 >> ~/.local/log/proton-backup.log 2>&1

# Blog/project backup at 2 AM
0 2 * * * proton-drive filesystem upload -f skip -d merge /home/elyons/Blog /my-files/FWAI01 >> ~/.local/log/proton-backup.log 2>&1
```

**Important:** Always include `-f` and `-d` flags in cron jobs. Without them, the CLI prompts for conflict resolution interactively and will hang waiting for input.

## Useful Commands

```bash
# List files with JSON output (great for scripting)
proton-drive filesystem list -j /my-files/FWAI01

# Check folder size
proton-drive filesystem size /my-files/FWAI01/Documents

# Full account export (takeout) — read-only, never modifies your drive
proton-drive takeout run -i my-files,photos,revisions ~/backup-takeout/

# Share a folder with someone
proton-drive sharing invite -u user@example.com -r viewer /my-files/FWAI01/Documents
```

## Why This Works for Me

- **Predictable:** Cron runs at known times, not random sync intervals
- **Auditable:** Log files show exactly what was uploaded each run
- **No background processes:** The CLI only runs when it needs to
- **Delta uploads:** Only changed files transfer — fast after the initial backup
- **Privacy-first:** Proton Drive is end-to-end encrypted, and I control the sync behavior

The desktop app is fine if you want set-and-forget. But for people who like knowing exactly what's happening with their data, the CLI + cron combination gives you that visibility without sacrificing convenience.
