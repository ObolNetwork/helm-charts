# DV-Pod Quickstart Guide

This guide covers deploying a Distributed Validator (DV) node using the dv-pod Helm chart with automatic DKG orchestration.

## Prerequisites

- Kubernetes cluster with kubectl access
- Helm 3.x installed
- Namespace created: `kubectl create namespace dv-pod`
- Ethereum wallet address for operator signature
- A synced consensus client (beacon node) for the same network. In the Obol Stack the chart defaults to
  `http://ethereum-beacon.ethereum-<network>.svc.cluster.local:5052` (from `obol network install ethereum --network <network>`)

## Scenario 1: Fresh Start (Automatic ENR Generation)

Use this if you're creating a new DV cluster from scratch.

### Step 1: Deploy DV-Pod with Auto-DKG

Each operator deploys their node:

```bash
helm upgrade --install my-dv-pod obol/dv-pod \
  --set mode=launchpad \
  --set charon.operatorAddress=0xYOUR_OPERATOR_ADDRESS \
  --set network=mainnet \
  --set 'charon.beaconNodeEndpoints[0]=http://YOUR_BEACON_NODE:5052' \
  --namespace=dv-pod \
  --timeout=10m --create-namespace
```

**What happens:**
1. The ENR job generates a new ENR private key and public ENR
2. Stores the key in the Secret **`my-dv-pod-enr-key`** (`<fullname>-enr-key`) and the public ENR in the ConfigMap **`my-dv-pod-enr`**
3. The DKG sidecar starts and waits for the cluster invite; progress is in the ConfigMap `my-dv-pod-dkg-status`

**Note on secret naming:** an existing `charon-enr-private-key` Secret in the namespace (from an older chart or
created by hand) is adopted instead, as long as no other release uses it. See "ENR identity" in the README.

### Step 2: Retrieve Your ENR

After deployment, get your public ENR to add to the Launchpad (no Secret access needed):

```bash
kubectl get configmap my-dv-pod-enr -n dv-pod -o jsonpath='{.data.enr}'
```

### Step 3: Create Cluster and Add ENR on Obol Launchpad

Follow the official Obol documentation to create your cluster and add your ENR:

**[Create a DV with a Group - Operator Guide](https://docs.obol.org/run-a-dv/start/create-a-dv-with-a-group#operator)**

Summary:
1. Visit [Obol Launchpad](https://launchpad.obol.org)
2. Create a new cluster OR accept an existing cluster invitation
3. Connect your wallet with the operator address you configured
4. Paste the ENR from Step 2 (this pod's ENR; the sidecar only matches a definition containing it)
5. Sign the cluster configuration with your operator wallet

The sidecar does not sign anything itself. Once all operators have signed on the Launchpad, it runs the DKG ceremony automatically.

### Step 4: Wait for DKG Completion

Monitor progress:

```bash
# Phase: WaitingForInvite -> WaitingForSignatures -> DefinitionReady -> Complete
kubectl get configmap my-dv-pod-dkg-status -n dv-pod -o jsonpath='{.data.phase}{"\n"}{.data.message}{"\n"}'

# Watch the sidecar, then the DKG ceremony itself
kubectl logs -n dv-pod my-dv-pod-0 -c dkg-sidecar --follow
kubectl logs -n dv-pod my-dv-pod-0 -c charon-dkg --follow
```

When all operators complete, Charon automatically starts validating.

---

## Scenario 1b: Direct route (cluster definition, no Launchpad invite)

If someone created the cluster definition with `charon create dkg --publish` (using each operator's ENR from
Step 2), install with its config hash instead of an operator address:

```bash
helm upgrade --install my-dv-pod obol/dv-pod \
  --set mode=definition \
  --set dkg.definition.configHash=0xCONFIG_HASH \
  --set network=hoodi \
  --set 'charon.beaconNodeEndpoints[0]=http://YOUR_BEACON_NODE:5052' \
  --namespace=dv-pod --create-namespace
```

`dkg.definition.url` (HTTPS) and `dkg.definition.configMap` (a ConfigMap holding `cluster-definition.json`) work
the same way. All operators' pods must be running at the same time for the DKG.

---

## Scenario 2: Join Existing Cluster (Import Existing ENR)

Use this if you already have an ENR from a previous DV setup or want to join a specific cluster.

### Prerequisites

You need:
- Your existing ENR private key file (e.g., from `.charon/charon-enr-private-key`)
- Your public ENR string (starts with `enr:`)
- Target cluster config hash from the Obol Launchpad
- Namespace created: `kubectl create namespace dv-pod`

### Step 1: Create ENR Secret

**IMPORTANT:** The secret must have these exact key names:

```bash
# Method 1: Using kubectl create (recommended)
kubectl create secret generic charon-enr-private-key -n dv-pod \
  --from-file=charon-enr-private-key=/full/path/to/your/charon-enr-private-key \
  --from-literal=enr="enr:-...your-public-enr-here..."

# Method 2: From existing .charon directory
kubectl create secret generic charon-enr-private-key -n dv-pod \
  --from-file=.charon/charon-enr-private-key \
  --from-literal=enr="enr:-...your-public-enr-here..."
```

**Verify the secret:**

```bash
kubectl get secret charon-enr-private-key -n dv-pod -o jsonpath='{.data}' | jq 'keys'
```

Expected output: `["charon-enr-private-key", "enr"]`

### Step 2: Deploy DV-Pod Targeting Specific Cluster

```bash
helm upgrade --install my-dv-pod obol/dv-pod \
  --set charon.operatorAddress=0xYOUR_OPERATOR_ADDRESS \
  --set mode=launchpad \
  --set charon.dkgSidecar.targetConfigHash=0xYOUR_CONFIG_HASH \
  --set network=mainnet \
  --set 'charon.beaconNodeEndpoints[0]=http://YOUR_BEACON_NODE:5052' \
  --set charon.enr.existingSecret.name=charon-enr-private-key \
  --namespace=dv-pod \
  --timeout=10m
```

**What happens:**
1. ENR job detects existing secret and skips generation
2. DKG sidecar reads your existing ENR
3. Fetches the specific cluster using targetConfigHash
4. Validates your ENR matches the cluster definition
5. Waits for all operators (including you, on the Launchpad) to sign
6. Runs DKG ceremony when ready

### Step 3: Monitor DKG Progress

```bash
kubectl get configmap my-dv-pod-dkg-status -n dv-pod -o jsonpath='{.data.phase}{"\n"}'
kubectl logs -n dv-pod my-dv-pod-0 -c dkg-sidecar --follow
```

---

## Configuration Options

### Network Selection

```bash
# Mainnet (default)
--set network=mainnet

# Hoodi testnet
--set network=hoodi

# Sepolia testnet
--set network=sepolia
```

Set `network` at install time: the DKG sidecar only looks for cluster invites on that network.

### Custom DKG Sidecar Image

```bash
--set charon.dkgSidecar.image.repository=your-registry/charon-dkg-sidecar \
--set charon.dkgSidecar.image.tag=v1.1.0 \
--set charon.dkgSidecar.image.pullPolicy=Always
```

### Beacon Node Configuration

```bash
# Single beacon node
--set 'charon.beaconNodeEndpoints[0]=http://beacon:5052'

# Obol Stack beacon node: the default when unset (ethereum-<network>); set it only if your
# deployment has another id (see `obol network list`)
--set 'charon.beaconNodeEndpoints[0]=http://ethereum-beacon.ethereum-<id>.svc.cluster.local:5052'

# Multiple beacon nodes (primary + fallbacks)
# If no fallback is set, the public publicnode.com beacon API for `network` is used (disable with charon.publicnodeFallback=false)
--set 'charon.beaconNodeEndpoints[0]=http://primary-beacon:5052' \
--set 'charon.fallbackBeaconNodeEndpoints[0]=http://fallback-beacon:5052' \
--set 'charon.fallbackBeaconNodeEndpoints[1]=http://backup-beacon:5052'
```

### Validator Client Selection

```bash
# Lighthouse (default)
--set validatorClient.type=lighthouse

# Teku
--set validatorClient.type=teku

# Prysm (by choosing Prysm you accept its Terms of Use; the chart passes --accept-terms-of-use)
--set validatorClient.type=prysm

# Lodestar
--set validatorClient.type=lodestar

# Nimbus
--set validatorClient.type=nimbus
```

---

## Troubleshooting

### Check ENR Job Status

```bash
kubectl get jobs -n dv-pod
kubectl logs job/my-dv-pod-enr-job -n dv-pod
```

### View DKG Sidecar Logs

```bash
kubectl logs -n dv-pod my-dv-pod-0 -c dkg-sidecar --follow
```

### ENR Mismatch Error

If you see "ENR MISMATCH" in logs:
- Your ENR doesn't match what's registered in the cluster
- Either update the cluster definition with your current ENR
- Or recreate your secret with the ENR expected by the cluster

### Secret Key Name Error

The secret MUST have these exact keys:
- `charon-enr-private-key` (NOT `private-key`)
- `enr` (NOT `public-enr`)

**Check your secret:**
```bash
kubectl get secret <your-enr-secret> -n dv-pod -o json | jq -r '.data | keys'
```

### DKG Polling Forever

If DKG sidecar keeps polling:
- Verify your operator address matches the Launchpad
- Check you've accepted the cluster on the Launchpad
- Ensure all operators have signed the cluster definition
- Verify targetConfigHash matches your cluster

---

## Verification

### Test the Deployment

```bash
helm test my-dv-pod -n dv-pod
```

### Check Charon Status

```bash
# View Charon logs
kubectl logs -n dv-pod my-dv-pod-0 -c dv-pod --tail=50

# Check validator client logs
kubectl logs -n dv-pod my-dv-pod-0 -c validator-client --tail=50

# Check Prometheus metrics
kubectl port-forward -n dv-pod my-dv-pod-0 3620:3620
# Visit: http://localhost:3620/metrics
```

---

## Important Notes

1. **ENR Private Key Security**: The ENR private key is crucial for DV operations. Always backup secrets.

2. **Automatic DKG**: The DKG sidecar automatically handles cluster discovery and DKG ceremony execution once all operators have signed on the Launchpad. It does not accept or sign invites itself.

3. **Target Config Hash**: Use `targetConfigHash` to specify exactly which cluster to join. Without it, the sidecar will join the most recent cluster where your operator is invited.

4. **ENR Secret Auto-Detection**: If a secret named `charon-enr-private-key` exists in the namespace and no other release uses it, it's adopted. Prefer setting `charon.enr.existingSecret.name` explicitly.

5. **Namespace Isolation**: ENR secrets are only detected in the same namespace as the Helm release.

6. **Secret Naming**: Generated identities use the per-release name `<fullname>-enr-key` (e.g. `my-dv-pod-enr-key`), so two releases in one namespace never share an identity. An identity is never regenerated on upgrade.

7. **Back up** `/charon-data` (cluster-lock and key shares) after the DKG; see "Backing up charon-data" in the README.

---

## Next Steps

After successful DKG:
1. Verify cluster-lock.json was created
2. Monitor validator duties in beacon chain explorers
3. Set up monitoring with Prometheus/Grafana
4. Configure alerting for validator performance

For more details, see the [full README](./README.md) and [Obol Documentation](https://docs.obol.org).
