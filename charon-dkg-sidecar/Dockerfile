# Build stage
FROM node:20-alpine AS builder

WORKDIR /app

# Copy package files
COPY package.json pnpm-lock.yaml ./

# Install pnpm and dependencies
RUN npm install -g pnpm && pnpm install --frozen-lockfile

# Copy source code
COPY tsconfig.json ./
COPY src/ ./src/

# Build the application
RUN pnpm run build

# Runtime stage
FROM node:20-alpine

# Install required tools
RUN apk add --no-cache curl jq bash

WORKDIR /app

# Copy package files and install production dependencies only
COPY package.json pnpm-lock.yaml ./
RUN npm install -g pnpm && pnpm install --prod --frozen-lockfile && npm uninstall -g pnpm

# Copy built application from builder stage
COPY --from=builder /app/dist ./dist

# Create non-root user
RUN addgroup -g 1001 -S charon && \
    adduser -S -u 1001 -G charon charon

# Set ownership
RUN chown -R charon:charon /app

# Switch to non-root user
USER charon

# Default environment variables
ENV NODE_ENV=production \
    LOG_LEVEL=INFO \
    API_ENDPOINT=https://api.obol.tech \
    ENR_FILE_PATH=/enr-from-job/enr.txt \
    OUTPUT_DEFINITION_FILE=/charon-data/cluster-definition.json \
    CHARON_NODE_ID_DIR=/charon-data \
    CHARON_PRIVATE_KEY_FILE=/charon-data/charon-enr-private-key \
    INITIAL_RETRY_INTERVAL_SECONDS=10 \
    MAX_RETRY_INTERVAL_SECONDS=300 \
    BACKOFF_FACTOR=2 \
    PAGE_LIMIT=10

# Entry point
ENTRYPOINT ["node", "/app/dist/dkg-sidecar.js"]