# DV-Pod Quickstart Guide

This guide covers deploying a Distributed Validator (DV) node using the dv-pod Helm chart with automatic DKG orchestration.

## Prerequisites

- Kubernetes cluster with kubectl access
- Helm 3.x installed
- Namespace created: `kubectl create namespace dv-pod`
- Ethereum wallet address for operator signature

## Scenario 1: Fresh Start (Automatic ENR Generation)

Use this if you're creating a new DV cluster from scratch.

### Step 1: Deploy DV-Pod with Auto-DKG

Each operator deploys their node:

```bash
helm upgrade --install my-dv-pod charts/dv-pod/ \
  --set charon.operatorAddress=0xYOUR_OPERATOR_ADDRESS \
  --set network=mainnet \
  --namespace=dv-pod \
  --timeout=10m --create-namespace
```

**What happens:**
1. ENR job automatically generates a new ENR private key and public ENR
2. Stores them in a secret: **`charon-enr-private-key`** (default name)
3. DKG sidecar starts and waits for cluster configuration

**Note on secret naming:**
- By default, the secret is named `charon-enr-private-key` (configured via `secrets.defaultEnrPrivateKey`)
- To use release-based naming like `my-dv-pod-enr-key`, set: `--set secrets.defaultEnrPrivateKey=""`
- Release-based naming is smart: it avoids duplication (e.g., `my-dv-pod` → `my-dv-pod-enr-key`, NOT `my-dv-pod-dv-pod-enr-key`)

### Step 2: Retrieve Your ENR

After deployment, get your public ENR to add to the Launchpad:

```bash
# Default secret name
kubectl get secret charon-enr-private-key -n dv-pod \
  -o jsonpath='{.data.enr}' | base64 -d

# OR if you used release-based naming (--set secrets.defaultEnrPrivateKey="")
kubectl get secret my-dv-pod-enr-key -n dv-pod \
  -o jsonpath='{.data.enr}' | base64 -d
```

### Step 3: Create Cluster and Add ENR on Obol Launchpad

Follow the official Obol documentation to create your cluster and add your ENR:

**[Create a DV with a Group - Operator Guide](https://docs.obol.org/run-a-dv/start/create-a-dv-with-a-group#operator)**

Summary:
1. Visit [Obol Launchpad](https://launchpad.obol.org)
2. Create a new cluster OR accept an existing cluster invitation
3. Connect your wallet with the operator address you configured
4. Paste your ENR from Step 2
5. Sign the cluster configuration

Once all operators have signed, the DKG ceremony will automatically begin.

### Step 4: Wait for DKG Completion

Monitor progress:

```bash
# Watch DKG sidecar logs
kubectl logs -n dv-pod -l app.kubernetes.io/instance=my-dv-pod -c dkg-sidecar --follow

# Check if cluster-lock was created
kubectl exec -n dv-pod my-dv-pod-dv-pod-0 -- ls -la /charon-data/
```

When all operators complete, Charon automatically starts validating.

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
helm upgrade --install my-dv-pod charts/dv-pod/ \
  --set charon.operatorAddress=0xYOUR_OPERATOR_ADDRESS \
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
5. Automatically signs and accepts the cluster
6. Waits for all operators to sign
7. Runs DKG ceremony when ready

### Step 3: Monitor DKG Progress

```bash
# Watch DKG sidecar logs
kubectl logs -n dv-pod -l app.kubernetes.io/instance=my-dv-pod -c dkg-sidecar --follow

# Check for cluster-lock creation
kubectl exec -n dv-pod my-dv-pod-dv-pod-0 -- ls -la /charon-data/cluster-lock.json
```

---

## Configuration Options

### Network Selection

```bash
# Mainnet (default)
--set network=mainnet

# Sepolia testnet
--set network=sepolia

# Hoodi testnet
--set network=hoodi

# Gnosis Chain
--set network=gnosis
```

### Custom DKG Sidecar Image

```bash
--set charon.dkgSidecar.image.repository=your-registry/charon-dkg-sidecar \
--set charon.dkgSidecar.image.tag=v1.0.1 \
--set charon.dkgSidecar.image.pullPolicy=Always
```

### Beacon Node Configuration

```bash
# Single beacon node
--set 'charon.beaconNodeEndpoints[0]=http://beacon:5052'

# Multiple beacon nodes (primary + fallbacks)
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

# Prysm
--set validatorClient.type=prysm \
--set validatorClient.config.prysm.acceptTermsOfUse=true

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
kubectl logs job/my-dv-pod-dv-pod-enr-job -n dv-pod
```

### View DKG Sidecar Logs

```bash
kubectl logs -n dv-pod my-dv-pod-dv-pod-0 -c dkg-sidecar --follow
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
kubectl get secret charon-enr-private-key -n dv-pod -o json | jq -r '.data | keys'
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
kubectl logs -n dv-pod my-dv-pod-dv-pod-0 -c charon --tail=50

# Check validator client logs
kubectl logs -n dv-pod my-dv-pod-dv-pod-0 -c validator-client --tail=50

# Check Prometheus metrics
kubectl port-forward -n dv-pod my-dv-pod-dv-pod-0 3620:3620
# Visit: http://localhost:3620/metrics
```

---

## Important Notes

1. **ENR Private Key Security**: The ENR private key is crucial for DV operations. Always backup secrets.

2. **Automatic DKG**: The DKG sidecar automatically handles cluster discovery, acceptance, and DKG ceremony execution when all operators are ready.

3. **Target Config Hash**: Use `targetConfigHash` to specify exactly which cluster to join. Without it, the sidecar will join the most recent cluster where your operator is invited.

4. **ENR Secret Auto-Detection**: If a secret named `charon-enr-private-key` exists in the namespace, it's automatically used. No need to set `charon.enr.existingSecret.name`.

5. **Namespace Isolation**: ENR secrets are only detected in the same namespace as the Helm release.

6. **Secret Naming**: By default, auto-generated secrets use the name `charon-enr-private-key`. To use release-based naming (`{release-name}-dv-pod-enr-key`), set `secrets.defaultEnrPrivateKey=""`.

---

## Next Steps

After successful DKG:
1. Verify cluster-lock.json was created
2. Monitor validator duties in beacon chain explorers
3. Set up monitoring with Prometheus/Grafana
4. Configure alerting for validator performance

For more details, see the [full README](./README.md) and [Obol Documentation](https://docs.obol.org).
