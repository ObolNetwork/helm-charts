# DKG Sidecar TypeScript Implementation

This directory contains both the original shell script (`dkg-sidecar.sh`) and the new TypeScript implementation (`dkg-sidecar.ts`) of the DKG sidecar logic.

## TypeScript Implementation

The TypeScript version provides:
- Better error handling and type safety
- Integration with the Obol SDK for API interactions
- Support for accepting cluster definitions
- Improved logging and debugging capabilities

### Building

To build the TypeScript version locally:

```bash
cd scripts
npm install
npm run build
```

This will compile `dkg-sidecar.ts` to `dkg-sidecar.js`.

### Docker Image

The TypeScript version is packaged in a Docker image that extends the base Charon image. The Dockerfile is located at `../dkg-sidecar/Dockerfile`.

To build the Docker image:

```bash
cd ../dkg-sidecar
docker build -t dkg-sidecar:latest -f Dockerfile ..
```

### Environment Variables

The TypeScript implementation supports the following environment variables:

- `OPERATOR_ADDRESS`: The operator's Ethereum address
- `ENR_FILE_PATH`: Path to the ENR file (default: `/enr-from-job/enr.txt`)
- `OUTPUT_DEFINITION_FILE`: Path to save the cluster definition (default: `/charon-data/cluster-definition.json`)
- `API_ENDPOINT`: Obol API endpoint (default: `https://api.obol.tech`)
- `INITIAL_RETRY_INTERVAL_SECONDS`: Initial retry delay (default: `10`)
- `MAX_RETRY_INTERVAL_SECONDS`: Maximum retry delay (default: `300`)
- `BACKOFF_FACTOR`: Retry backoff factor (default: `2`)
- `PAGE_LIMIT`: API pagination limit (default: `10`)
- `CHARON_NODE_ID_DIR`: Charon data directory (default: `/charon-data`)
- `CHARON_PRIVATE_KEY_FILE`: Path to Charon private key for signing (optional)

### Backward Compatibility

The `dkg-sidecar-wrapper.sh` script provides backward compatibility with the existing shell script interface. It automatically detects whether the TypeScript version is available and falls back to the shell script if needed.
