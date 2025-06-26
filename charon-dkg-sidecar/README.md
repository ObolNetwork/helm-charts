# Charon DKG Sidecar

![Build Status](https://github.com/ObolNetwork/charon-dkg-sidecar/workflows/CI/badge.svg)
![Docker Pulls](https://img.shields.io/docker/pulls/obolnetwork/charon-dkg-sidecar)
![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)

A Kubernetes sidecar container that orchestrates the Distributed Key Generation (DKG) process for Obol Network's Charon distributed validators.

## Overview

The Charon DKG Sidecar is designed to run as an init container in Kubernetes deployments, handling the complete lifecycle of distributed validator setup:

1. **Polling** - Monitors the Obol API for cluster invitations matching the operator address
2. **Validation** - Ensures the cluster definition is properly signed by all operators
3. **DKG Execution** - Initiates the Charon DKG process when all operators are ready
4. **Persistence** - Saves the resulting cluster lock file for the main Charon container

## Features

- Automatic polling with exponential backoff
- Support for paginated API responses
- ENR (Ethereum Node Record) validation
- Cluster definition signature verification
- Automatic acceptance of cluster invitations
- Comprehensive logging with configurable levels
- Built-in retry logic for resilient operation

## Usage

### Docker

```bash
docker run -v /path/to/data:/charon-data \
  -e OPERATOR_ADDRESS=0xYourOperatorAddress \
  -e ENR_FILE_PATH=/enr-from-job/enr.txt \
  ghcr.io/obolnetwork/charon-dkg-sidecar:latest
```

### Kubernetes Init Container

```yaml
initContainers:
  - name: dkg-sidecar
    image: ghcr.io/obolnetwork/charon-dkg-sidecar:latest
    env:
      - name: OPERATOR_ADDRESS
        value: "0xYourOperatorAddress"
      - name: ENR_FILE_PATH
        value: "/enr-from-job/enr.txt"
      - name: OUTPUT_DEFINITION_FILE
        value: "/charon-data/cluster-definition.json"
      - name: API_ENDPOINT
        value: "https://api.obol.tech"
    volumeMounts:
      - name: enr-data
        mountPath: /enr-from-job
        readOnly: true
      - name: charon-data
        mountPath: /charon-data
```

## Configuration

The sidecar is configured through environment variables:

| Variable | Description | Default |
|----------|-------------|---------|
| `OPERATOR_ADDRESS` | Ethereum address of the operator | Required |
| `ENR_FILE_PATH` | Path to the ENR file | `/enr-from-job/enr.txt` |
| `OUTPUT_DEFINITION_FILE` | Path to save the cluster definition | `/charon-data/cluster-definition.json` |
| `API_ENDPOINT` | Obol API endpoint | `https://api.obol.tech` |
| `CHARON_NODE_ID_DIR` | Directory for Charon data | `/charon-data` |
| `CHARON_PRIVATE_KEY_FILE` | Path to Charon ENR private key | `/charon-data/charon-enr-private-key` |
| `INITIAL_RETRY_INTERVAL_SECONDS` | Initial retry delay | `10` |
| `MAX_RETRY_INTERVAL_SECONDS` | Maximum retry delay | `300` |
| `BACKOFF_FACTOR` | Exponential backoff multiplier | `2` |
| `PAGE_LIMIT` | API pagination limit | `10` |
| `LOG_LEVEL` | Logging level (DEBUG, INFO, WARN, ERROR) | `INFO` |

## Development

### Prerequisites

- Node.js 20+
- pnpm

### Setup

```bash
# Clone the repository
git clone https://github.com/ObolNetwork/charon-dkg-sidecar.git
cd charon-dkg-sidecar

# Install dependencies
pnpm install

# Build the TypeScript code
pnpm run build

# Run in development mode
pnpm run dev
```

### Building Docker Image

```bash
# Build for local architecture
docker build -t charon-dkg-sidecar:local .

# Build for multiple architectures
docker buildx build --platform linux/amd64,linux/arm64 -t charon-dkg-sidecar:local .
```

## Architecture

The sidecar follows a polling-based architecture:

1. **Initialization**: Validates configuration and loads ENR
2. **Polling Loop**: 
   - Fetches cluster definitions from the Obol API
   - Checks for definitions where the operator has signed the ENR
   - Validates all operators have signed
3. **DKG Process**:
   - Saves the cluster definition
   - Executes `charon dkg` command
   - Handles success/failure scenarios
4. **Exit**: Completes successfully or retries on failure

## Error Handling

- Missing operator address results in immediate failure
- API errors trigger exponential backoff retry
- DKG failures clean up artifacts and retry
- Existing cluster lock files bypass the entire process

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request. For major changes, please open an issue first to discuss what you would like to change.

## License

This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) file for details.

## Support

For support and questions:
- [Obol Discord](https://discord.gg/obol)
- [GitHub Issues](https://github.com/ObolNetwork/charon-dkg-sidecar/issues)