#!/bin/bash

# Setup script to enable git hooks for this repository

echo "Setting up git hooks to prevent sensitive data leaks..."

# Configure git to use the .githooks directory
git config core.hooksPath .githooks

echo "✅ Git hooks configured successfully!"
echo "The pre-commit hook will now prevent committing:"
echo "  - Cluster test data (canary-*, node*)"
echo "  - Private keys and keystores"
echo "  - Large files (node_modules, etc.)"
echo ""
echo "To temporarily bypass (NOT recommended): git commit --no-verify"