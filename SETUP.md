# Blog Setup Guide

## Quick Start Commands (Run in Terminal)

### 1. Enable Tailscale Serve Without Sudo (One-Time Setup)
```bash
sudo tailscale set --operator=$USER
```

### 2. Expose Your Blog Over HTTPS on Tailnet
```bash
cd ~/Blog && make serve
```

This will:
- Build the Hugo site (`make build`)
- Start Tailscale serve to expose port 1313 over HTTPS
- Make your blog accessible at `https://fwai01.<your-tailnet>.ts.net`

### 3. (Optional) Expose Forgejo Web Interface Too
```bash
tailscale serve http://:80=http://localhost:3000
```
This makes Forgejo accessible at `https://forgejo-1.<your-tailnet>.ts.net`

## Development Workflow

| Command | What it does |
|---------|--------------|
| `make dev` | Start Hugo server with live reload (http://localhost:1313) |
| `make build` | Generate static site to `public/` directory |
| `make serve` | Expose blog via Tailscale HTTPS |
| `make push` | Build, commit changes, and push to Forgejo |

## Writing New Posts

When you want to write a new post:
1. Tell me what topic/content you want
2. I'll create the markdown file in `content/posts/YYYY-MM-DD-slug.md` with proper YAML frontmatter
3. We review together
4. Set `draft: false` when ready
5. Run `make push` to build and publish

## Access URLs

- **Local preview**: http://localhost:1313 (while running `make dev`)
- **Tailscale (private)**: https://fwai01.<your-tailnet>.ts.net (after `make serve`)
- **Forgejo repo**: http://forgejo-1:3000/elyons/blog

## Migration Path

When you're ready to go public, this setup makes it easy to migrate:
- Content is just markdown files (portable)
- Hugo builds are static HTML (host anywhere)
- Just push to a new host (Cloudflare Pages, Netlify, VPS with nginx, etc.)
- No database or backend to maintain
