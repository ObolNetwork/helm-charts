# Troubleshooting Guide

## Recovering .charon Directory After DKG

After a successful Distributed Key Generation (DKG) ceremony, you may need to recover the `.charon` directory from the Kubernetes pod to share with peers or for backup purposes.

### Recovery Steps

1. **Create a local recovery directory:**
   ```bash
   mkdir -p ~/charon-recovery
   ```

2. **Copy the .charon directory from the pod:**
   ```bash
   kubectl cp <namespace>/<pod-name>:/charon-data/ ~/charon-recovery/.charon -c validator-client
   ```

   Replace:
   - `<namespace>` - Your Kubernetes namespace (e.g., `obol-stack-test-cluster`)
   - `<pod-name>` - The dv-pod pod name (e.g., `<release-name>-0`)

3. **Verify the recovery:**
   ```bash
   ls -la ~/charon-recovery/.charon
   ```

   You should see:
   - `cluster-lock.json` - The finalized cluster configuration
   - `cluster-definition.json` - The original cluster definition
   - `deposit-data.json` - Validator deposit data
   - `validator_keys/` - Directory containing keystore files and passwords

4. **Create an archive for sharing (optional):**
   ```bash
   cd ~/charon-recovery
   tar -czf charon-cluster-backup.tar.gz .charon/
   ```

### What Gets Recovered

The `.charon` directory contains all outputs from the DKG ceremony:

- **cluster-lock.json**: Distributed validator cluster configuration with operator ENRs and validator public keys
- **cluster-definition.json**: Original DKG ceremony parameters
- **deposit-data.json**: Ethereum deposit data for the validators (needed for staking deposits)
- **validator_keys/**: Individual validator keystores and their passwords (2 files per validator)

### Sharing with Peers

After recovery, you can share the relevant files with your cluster peers:
- Each operator needs their own validator keystores from the `validator_keys/` directory
- All operators need the same `cluster-lock.json` file
- The `deposit-data.json` is needed by whoever will submit the validator deposits

**Security Note**: Handle validator keystores and passwords with extreme care. Never share keystores over insecure channels.
