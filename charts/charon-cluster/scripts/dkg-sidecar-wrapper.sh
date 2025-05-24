#!/bin/sh
# Wrapper script to maintain backward compatibility with the existing shell script interface

# This script is called from the Helm templates and passes arguments to the TypeScript implementation

# Check if we're running in the container with the TypeScript version
if [ -f "/app/dkg-sidecar.js" ]; then
    # Run the TypeScript version
    exec node /app/dkg-sidecar.js "$@"
else
    # Fall back to the original shell script if TypeScript version is not available
    exec /scripts/dkg-sidecar.sh "$@"
fi
