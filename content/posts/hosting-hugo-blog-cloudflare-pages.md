---
title: "Hosting a Hugo Blog on Cloudflare Pages with a Custom Domain"
date: 2026-10-27
tags:
  - "Tech/DevOps"
  - "Privacy"
aliases: []
draft: false
---

## The Problem

I run my blog as a static Hugo site and initially hosted it on a self-hosted Forgejo instance behind Tailscale. I covered that setup in [my earlier post about setting up the blog with Forgejo and Tailscale](/posts/setup-blog/). That worked fine for tailnet-only access, but I wanted to make the blog publicly available without exposing my home network to the internet, no DDoS vectors, no port forwarding, no risk of someone finding an open SSH or web service on my LAN.

I also own the domain `mtnlyons.dev`, which is already managed through Cloudflare's nameservers. This gave me a natural starting point.

## Prerequisites

- A Hugo site (I use the [Console theme](https://github.com/mrmierzejewski/hugo-theme-console))
- A GitHub account, I already had one, but any Git host works
- A domain managed on Cloudflare (`mtnlyons.dev` in my case)
- The `cf` CLI installed (optional, used for initial project creation)

## Step 1: Push Your Hugo Site to GitHub

Make sure your entire site is tracked in Git, including theme files. I ran into an issue where the `.gitignore` had `themes/` listed, which excluded my theme from the repo and caused build failures on Cloudflare's end. Fix it by removing that line and committing everything:

```bash
cd /path/to/blog
# Remove themes/ from .gitignore if present
git add -A
git commit -m "Add all site files including theme"
git push origin main
```

## Step 2: Create the Pages Project

Go to **Workers & Pages → Create application → Continue to Pages** (at the bottom of the wizard, look for "Need to use the legacy Pages workflow?"). Then select your GitHub account and choose the repository that contains your Hugo site. I used the `cf` CLI to create a project initially, but ran into problems because it was set up as a Workers project rather than a proper Pages project. The key lesson here is to use the Cloudflare dashboard's Pages setup wizard instead; it gives you better control over build settings.

## Step 3: Configure Build Settings

After selecting your repo, Cloudflare will ask you to configure the build. Set these values:

- **Framework preset:** Select "Hugo" from the dropdown
- **Production branch:** `main`
- **Build command:** `hugo --minify`
- Leave everything else as default

The `-minify` flag compresses the output, reducing bandwidth and load times. Cloudflare Pages runs this build on every push to your production branch, so no manual deployment is needed.

## Step 4: Add Your Custom Domain

Go to **Workers & Pages → blog → Custom Domains** and add your desired subdomain (e.g., `blog.yourdomain.com`). If you already have a CNAME record pointing the subdomain to your Pages URL, delete it first; Cloudflare will create its own managed DNS record when you add the custom domain.

Cloudflare automatically provisions an SSL certificate for your domain. This usually takes 1-2 minutes, after which your site is live at `https://blog.yourdomain.com`.

## Step 5: Fix Hugo Config Deprecations

Newer versions of Hugo (v0.128+) deprecated the `paginate` config key in favor of `pagination.pagerSize`. If your build fails on Cloudflare with a deprecation error, update your `hugo.toml`:

```toml
# Old (deprecated)
paginate = 10

# New
pagination = { pagerSize = 10 }
```

## What I Did Differently from My First Attempt

I originally set up the blog on Forgejo (self-hosted Git) and served it through Tailscale. That approach works for private access but has limitations:

- **No public HTTPS** without a reverse proxy and certificate management
- **Home network exposure risk** if you open ports to serve publicly
- **Manual deployments** requires running `make push` or similar for every post change
- **Single point of failure** because your home machine needs to be online for the site to exist

Cloudflare Pages solves all of these: the build runs on Cloudflare's infrastructure, deployment is automatic, and your home network stays completely isolated. The only thing I need from my end is a Git push.

## Going Forward

The workflow is now simple:

1. Write a post in Markdown
2. Commit and push to GitHub
3. Cloudflare builds and deploys automatically, usually within 60 seconds

No SSH, no port forwarding, no server maintenance. Just Markdown pushed to Git, served from the edge.

For backups of my desktop files (not just the blog), I use a similar approach with Proton Drive CLI and cron jobs , [see that post here](/posts/backing-up-desktop-files-with-proton-drive-cli/).
