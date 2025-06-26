.PHONY: help build test lint docker-build docker-push clean install dev

# Default target
help:
	@echo "Available targets:"
	@echo "  install       - Install dependencies"
	@echo "  build         - Build TypeScript to JavaScript"
	@echo "  dev           - Run in development mode"
	@echo "  lint          - Run linters"
	@echo "  test          - Run tests"
	@echo "  docker-build  - Build Docker image"
	@echo "  docker-push   - Push Docker image to registry"
	@echo "  clean         - Clean build artifacts"

# Install dependencies
install:
	pnpm install --frozen-lockfile

# Build TypeScript
build: install
	pnpm run build

# Development mode
dev:
	pnpm run dev

# Lint code
lint:
	@echo "Running linters..."
	pnpm run lint || true

# Run tests
test:
	@echo "No tests configured yet"

# Build Docker image
docker-build:
	docker build -t ghcr.io/obolnetwork/charon-dkg-sidecar:local .

# Build multi-platform Docker image
docker-buildx:
	docker buildx build --platform linux/amd64,linux/arm64 -t ghcr.io/obolnetwork/charon-dkg-sidecar:local .

# Push Docker image (requires authentication)
docker-push:
	@echo "Please use GitHub Actions for pushing images to the registry"

# Clean build artifacts
clean:
	rm -rf dist/
	rm -rf node_modules/
	rm -rf coverage/
	rm -rf .nyc_output/

# Version bump helpers
version-patch:
	npm version patch

version-minor:
	npm version minor

version-major:
	npm version major