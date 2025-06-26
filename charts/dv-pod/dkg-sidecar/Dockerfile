# Build stage
FROM node:22-bookworm-slim AS builder

WORKDIR /app

# Install build dependencies for native modules
RUN apt-get update && apt-get install -y python3 make g++ && rm -rf /var/lib/apt/lists/*

# Install pnpm
RUN npm install -g pnpm

# Copy package files and lockfile
COPY scripts/package*.json ./
COPY scripts/pnpm-lock.yaml ./
COPY scripts/tsconfig.json ./

# Install dependencies using pnpm
RUN pnpm install --frozen-lockfile

# Copy TypeScript source
COPY scripts/dkg-sidecar.ts ./

# Build TypeScript
RUN npm run build

# Production dependencies stage
FROM node:22-bookworm-slim AS prod-deps

WORKDIR /app

# Install build dependencies for native modules
RUN apt-get update && apt-get install -y python3 make g++ && rm -rf /var/lib/apt/lists/*

# Copy package files
COPY scripts/package*.json ./

# Install only production dependencies - npm will build native modules
RUN npm install --omit=dev

# Runtime stage - based on the charon image
FROM obolnetwork/charon:latest

# Switch to root user to install packages
USER root

# Install Node.js runtime
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    nodejs \
    npm \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy built JavaScript from builder
COPY --from=builder /app/dkg-sidecar.js ./
# Copy production dependencies from prod-deps stage
COPY --from=prod-deps /app/node_modules ./node_modules

# Switch to non-root user if it exists in the base image
USER charon

ENTRYPOINT ["node", "/app/dkg-sidecar.js"]
