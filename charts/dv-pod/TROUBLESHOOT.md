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

## DKG and identity

- **Where is it stuck?** `kubectl get cm <release>-dkg-status -o jsonpath='{.data.phase} {.data.message}'`, then the
  logs of the init container named in `kubectl get pod <release>-0` (`dkg-sidecar`, `charon-dkg`, `dkg-report`).
- **`charon-dkg` keeps retrying**: every operator's pod must be running the DKG at the same time, with the same charon
  minor version. Check peers' status and that relays (`https://*.relay.obol.tech`, TCP 3610) are reachable.
- **`charon-dkg` says the data dir contains `validator_keys/` but no lock**: an earlier DKG wrote partial output.
  The chart never deletes key material. Back up `/charon-data`, compare with your peers (did the DKG complete for
  them? is the lock published on the Obol API?), then clean up by hand.
- **"differs from the ENR private key in Secret"**: `/charon-data/charon-enr-private-key` was written with another
  identity. Find which identity the cluster definition/lock lists before changing anything.
- **ENR job "refusing to overwrite"**: the ENR Secret exists without the private key field. Fix the Secret or
  delete it (only if this identity is not in any cluster).
- **Two releases in one namespace shared `charon-enr-private-key`** (charts < 0.22): one of them has the wrong
  identity. Keep the Secret with the release whose ENR is in the cluster lock, and give the other release its own
  identity via `charon.enr.existingSecret.name`.
- **`ErrImagePull` for `charon-dkg-sidecar:v1.1.0`**: the tag isn't published yet; see the README.
