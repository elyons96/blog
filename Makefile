.PHONY: build dev serve push clean help

# Build the static site
build:
	@echo "Building Hugo site..."
	hugo --minify
	@echo "✓ Site built successfully! Output in public/"

# Start Hugo development server with live reload
dev:
	@echo "Starting Hugo dev server on http://localhost:1313"
	hugo server --buildDrafts --disableLiveReload=false

# Expose the site via Tailscale HTTPS
serve: build
	@echo "Exposing blog via Tailscale..."
	tailscale serve http://:80=http://localhost:1313 &
	@echo "✓ Blog is live at https://fwai01.<your-tailnet>.ts.net"

# Commit and push to Forgejo
push: build
	@git add -A
	@git commit -m "Update blog content" 2>/dev/null || echo "No changes to commit"
	@git push origin main
	@echo "✓ Changes pushed to http://forgejo-1:3000/elyons/blog"

# Clean build artifacts
clean:
	rm -rf public/ resources/
	@echo "✓ Build artifacts cleaned"

# Show help
help:
	@echo "Blog Commands:"
	@echo "  make build   - Generate static site to public/"
	@echo "  make dev     - Start Hugo server with live reload (localhost:1313)"
	@echo "  make serve   - Expose blog via Tailscale HTTPS"
	@echo "  make push    - Build, commit, and push to Forgejo"
	@echo "  make clean   - Remove build artifacts"
