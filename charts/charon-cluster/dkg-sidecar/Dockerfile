# Build stage
FROM node:18-alpine AS builder

WORKDIR /app

# Copy package files
COPY scripts/package*.json ./
COPY scripts/tsconfig.json ./

# Install dependencies
RUN npm ci

# Copy TypeScript source
COPY scripts/dkg-sidecar.ts ./

# Build TypeScript
RUN npm run build

# Runtime stage - based on the charon image
FROM obolnetwork/charon:latest

# Install Node.js runtime
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    nodejs \
    npm \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy built JavaScript and dependencies from builder
COPY --from=builder /app/dkg-sidecar.js ./
COPY --from=builder /app/package*.json ./
COPY --from=builder /app/node_modules ./node_modules

# Create script wrapper for backward compatibility
RUN echo '#!/bin/sh\nnode /app/dkg-sidecar.js "$@"' > /usr/local/bin/dkg-sidecar.sh && \
    chmod +x /usr/local/bin/dkg-sidecar.sh

ENTRYPOINT ["/usr/local/bin/dkg-sidecar.sh"]
