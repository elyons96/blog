# Blog Setup and Workflow

## Directory Structure

```
Blog/
├── hugo.toml          # Site configuration (title, theme, menu)
├── Makefile           # Build automation commands
├── README.md          # This file - workflow documentation
├── .gitignore         # Git ignore rules (.env excluded!)
├── content/
│   └── posts/         # Your blog markdown files go here
├── themes/
│   └── papermod/      # PaperMod theme (Hugo static site generator)
├── public/            # Generated HTML (auto-created, gitignored)
└── .env               # Forgejo credentials (gitignored!)
```

## How It Works

### The Workflow

1. **Write Content** → You and I collaborate to create markdown files in `content/posts/`
2. **Build Site** → `make build` runs Hugo to generate static HTML into `public/`
3. **Preview Locally** → `make dev` starts live-reload server at http://localhost:1313
4. **Publish via Tailscale** → `make serve` exposes site over HTTPS on your tailnet
5. **Version Control** → `make push` commits and pushes to Forgejo (http://forgejo-1:3000/elyons/blog)

### Content Format

Each blog post is a markdown file with YAML frontmatter:

```markdown
---
title: "My First Post"
date: 2026-08-13T10:00:00Z
draft: false
tags: [hugo, blogging]
summary: "A brief summary of the post"
---

Your blog content here...
```

### Building & Deploying

| Command | What it does |
|---------|--------------|
| `make build` | Generate static site to `public/` |
| `make dev` | Start Hugo server with live reload (http://localhost:1313) |
| `make serve` | Expose built site via Tailscale HTTPS |
| `make push` | Commit changes and push to Forgejo |

### Access URLs

- **Local preview**: http://localhost:1313
- **Tailscale (private)**: https://fwai01.<your-tailnet>.ts.net
- **Forgejo repo**: http://forgejo-1:3000/elyons/blog

## Writing Blog Posts

To create a new post, just tell me what you want to write about and I'll generate the markdown file with proper frontmatter. The workflow is simple:

1. You describe the topic/content
2. I create `content/posts/YYYY-MM-DD-slug.md` with YAML frontmatter
3. We review together
4. Set `draft: false` when ready
5. Build and publish!

## Migration Path

When you're ready to go public, this setup makes it easy to migrate:
- Content is just markdown files (portable)
- Hugo builds are static HTML (host anywhere)
- Just push to a new host (Cloudflare Pages, Netlify, VPS with nginx, etc.)
- No database or backend to maintain
