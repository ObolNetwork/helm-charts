# Contributing to Charon DKG Sidecar

Thank you for your interest in contributing to the Charon DKG Sidecar! This document provides guidelines and instructions for contributing.

## Development Setup

1. **Prerequisites**
   - Node.js 20 or higher
   - pnpm package manager
   - Docker for building images
   - Git

2. **Clone and Install**
   ```bash
   git clone https://github.com/ObolNetwork/charon-dkg-sidecar.git
   cd charon-dkg-sidecar
   pnpm install
   ```

3. **Build**
   ```bash
   pnpm run build
   ```

## Making Changes

1. **Create a Feature Branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Make Your Changes**
   - Write clean, documented code
   - Follow the existing code style
   - Add appropriate error handling
   - Update tests if applicable

3. **Test Your Changes**
   - Build the TypeScript: `pnpm run build`
   - Build the Docker image: `make docker-build`
   - Test with sample configurations

## Code Style

- Use TypeScript for all new code
- Follow existing naming conventions
- Add JSDoc comments for public functions
- Use meaningful variable and function names
- Keep functions focused and small

## Commit Guidelines

We follow conventional commits:
- `feat:` New features
- `fix:` Bug fixes
- `docs:` Documentation changes
- `style:` Code style changes (formatting, etc.)
- `refactor:` Code refactoring
- `test:` Test additions or changes
- `chore:` Build process or auxiliary tool changes

Example:
```
feat: add support for custom API endpoints
fix: handle empty cluster definitions gracefully
docs: update README with new environment variables
```

## Pull Request Process

1. **Before Submitting**
   - Ensure all tests pass
   - Update documentation if needed
   - Add entries to CHANGELOG if applicable

2. **PR Description**
   - Clearly describe the problem and solution
   - Include any relevant issue numbers
   - List any breaking changes

3. **Review Process**
   - PRs require at least one approval
   - Address review feedback promptly
   - Ensure CI checks pass

## Testing

### Local Testing

1. **Unit Tests** (when available)
   ```bash
   pnpm test
   ```

2. **Integration Testing**
   - Use the mock API server from the Helm chart
   - Test different scenarios (success, failure, retries)

3. **Docker Testing**
   ```bash
   docker run -e OPERATOR_ADDRESS=0x... \
              -e LOG_LEVEL=DEBUG \
              -v $(pwd)/test-data:/charon-data \
              ghcr.io/obolnetwork/charon-dkg-sidecar:local
   ```

## Release Process

1. Version bumps follow semantic versioning
2. Update CHANGELOG.md
3. Create a PR with version changes
4. After merge, create a GitHub release
5. CI/CD will automatically build and publish the Docker image

## Getting Help

- Join our [Discord](https://discord.gg/obol) for discussions
- Check existing issues before creating new ones
- Use clear, descriptive titles for issues and PRs

## Code of Conduct

Please be respectful and constructive in all interactions. We aim to maintain a welcoming and inclusive community.

Thank you for contributing!