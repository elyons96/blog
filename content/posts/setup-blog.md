---
title: "Setting Up My Hugo Blog with Forgejo and Tailscale"
date: 2026-08-13T17:00:00Z
draft: false
tags: [hugo, forgejo, tailscale, static-sites, devops]
summary: "Documenting the process of setting up a Hugo-powered blog with Forgejo for version control and Tailscale for private HTTPS access."
---

## The Goal

I wanted to start a blog where I could talk through technical topics while collaborating with an AI assistant. The key requirements were:

- Write content as markdown files (simple, portable)
- Use a static site generator (Hugo) for fast builds
- Version control with a local Forgejo instance
- Private HTTPS access via Tailscale (no public hosting yet)
- Easy migration path to production later

## The Setup Process

### Step 1: Installing Hugo and Forgejo

Both tools are standalone binaries, which makes deployment simple:

```bash
# Install Hugo extended binary
curl -sL https://github.com/gohugoio/hugo/releases/download/v0.165.0/hugo_extended_0.165.0_linux-amd64.tar.gz | tar xz -C ~/bin/

# Install Forgejo
curl -sL https://codeberg.org/forgejo/forgejo/releases/download/v16.0.2/forgejo-16.0.2-linux-amd64 -o ~/bin/forgejo
chmod +x ~/bin/forgejo
```

### Step 2: Creating the Hugo Site

```bash
cd ~/Blog && hugo new site . --force
git init
git submodule add https://github.com/yihui/hugo-theme-console.git themes/hugo-theme-console
```

The `hugo-theme-console` theme gives us a clean, console/terminal-inspired layout with responsive design that works well on both desktop and mobile devices.

### Step 3: Configuring Everything

Key files created:
- `hugo.toml` - Site configuration (theme, relative URLs for Tailscale compatibility)
- `assets/css/custom.css` - Custom CSS for mobile optimizations and theme styling
- `Makefile` - Build automation with commands like `make dev`, `make serve`, `make push`
- `.gitignore` - Excludes `.env`, `public/`, and build artifacts

### Step 4: Connecting to Forgejo

The existing Forgejo instance at `http://forgejo-1:3000/` was already running on our tailnet. We created the repository and pushed content:

```bash
git remote add origin http://forgejo-1:3000/elyons/blog.git
git push -u origin main
```

### Step 5: Tailscale Serve (The Tricky Part)

This was where we hit our first snag. The correct syntax for exposing the Hugo server is:

```bash
# First, enable tailscale serve without sudo (one-time setup)
sudo tailscale set --operator=$USER

# Then expose the blog over HTTPS on your tailnet
cd ~/Blog && make serve
```

The `make serve` command runs both `hugo build` and starts Tailscale serve to expose port 1313. Your blog becomes accessible at:
- **HTTPS**: `https://fwai01.<your-tailnet>.ts.net` (private, tailnet-only)

## The Workflow Going Forward

Now that everything is set up, the workflow is simple:

1. **Write Content** → I create markdown files in `content/posts/` with YAML frontmatter
2. **Build Site** → `make build` generates static HTML to `public/`
3. **Preview Locally** → `make dev` starts live-reload server at http://localhost:1313
4. **Publish via Tailscale** → `make serve` exposes site over HTTPS on tailnet
5. **Version Control** → `make push` commits and pushes to Forgejo

## Lessons Learned

- **Tailscale syntax matters**: The correct format is `tailscale serve 1313` (just the port number), not URL-based formats
- **Single binaries are great**: Both Hugo and Forgejo run as standalone executables - no Docker, no complex dependencies
- **Markdown-first approach**: Content stays portable regardless of hosting platform later
- **Custom CSS helps mobile styling**: Adding `assets/css/custom.css` fixes theme coloring on mobile devices
- **Relative URLs work best**: Setting `baseURL = "/"` and `relativeURLs = true` in `hugo.toml` ensures links work both locally and via Tailscale

## Next Steps

This is just the beginning. Future posts will cover:
- Technical deep-dives into infrastructure topics
- Web development experiences
- Lessons learned as a CTO
- Personal projects and experiments

The beauty of this setup is that content is just markdown files - we can migrate to Cloudflare Pages, Netlify, or any VPS with nginx later without changing the content workflow.

---

*This post was written collaboratively with an AI assistant using Hugo and the hugo-theme-console theme.*
