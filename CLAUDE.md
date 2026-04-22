# Claude Agent Guide: ObolNetwork/helm-charts

Kubernetes Helm charts for Obol products. Published as the `obol` Helm repo (Artifact Hub: https://artifacthub.io/packages/search?org=obol). The forward-preferred path for running a Distributed Validator (DV) in production at scale — use these when the user wants Kubernetes, a dedicated operator image, or the Obol Stack.

For the simpler Docker Compose launcher, see `ObolNetwork/charon-distributed-validator-node`.

## Chart inventory

| Chart | Version | App | Purpose |
|-------|---------|-----|---------|
| **`dv-pod`** ⭐ | 0.18.0 | Charon 1.9.3 | **Flagship.** Single DV node: Charon + VC, with automatic DKG orchestration. The default recommendation for "run a DV on k8s". |
| `obol-app` | 0.1.1 | latest | General-purpose "run any Docker image on the [Obol Stack](https://obol.org/stack)" chart. Not DV-specific — the Stack's generic service-deploy mechanism. |
| `charon` | 0.5.3 | 1.9.3 | Standalone Charon middleware (no VC). For bespoke stacks that wire their own VC. |
| `charon-cluster` | 0.4.3 | 1.9.3 | Multiple Charon instances in one release. Intended for test/local setups; **not** the production-operator path. |
| `charon-relay` | 0.5.0 | 1.9.3 | Hosts a Charon [p2p relay](https://docs.obol.org/learn/charon/charon-cli-reference#host-a-relay). |
| `remote-signer` | 0.3.0 | v0.1.0 | Lightweight Ethereum remote signer. |
| `aztec-node` | 2.2.1 | 4.1.3 | Aztec node (Full Node / Sequencer / Prover). Part of Obol Stack's Aztec support. |
| `openclaw` | 0.4.0 | 2026.3.2 | OpenClaw gateway (agent runtime). Note: the openclaw *skills* framework is being deprecated in favour of the `skills` repo designed for Claude agents; this chart remains for current operators. |
| `helios` | 0.1.5 | 0.9.0 | Helios light client. |

## Installing the repo

```bash
helm repo add obol https://obolnetwork.github.io/helm-charts/
helm repo update
helm search repo obol
```

Charts are GPG-signed (fingerprint `7010 534E 974B DE74 4608 A6D9 90C7 9327 34D7 8646`, pubkey `pubkey.asc`). Verify with `helm install --verify` when running in production.

## Flagship: `dv-pod`

Each operator in a DV cluster runs one `dv-pod` release. Killer feature: **automatic DKG orchestration** — the chart generates an ENR on first install, waits for cluster config, runs the DKG sidecar, and transitions to Charon+VC once the DKG artefact is ready.

### Minimal install

```bash
kubectl create namespace dv-pod
helm upgrade --install my-dv-pod obol/dv-pod \
  --set charon.operatorAddress=0xYOUR_OPERATOR_ADDRESS \
  --set chainId=1 \
  --namespace=dv-pod \
  --timeout=10m
```

`chainId` picks the network (1 = mainnet, 560048 = hoodi, 11155111 = sepolia). Equivalently, `--set network=mainnet|sepolia|hoodi` lets the chart derive the chainId itself — prefer this in examples for readability. After install, retrieve the generated ENR:

```bash
kubectl get secret charon-enr-private-key -n dv-pod \
  -o jsonpath='{.data.enr}' | base64 -d
```

Paste it into [launchpad.obol.org](https://launchpad.obol.org) to create or accept a cluster.

### Deep references in-chart

- `charts/dv-pod/QUICKSTART.md` — full onboarding: fresh start vs. rejoining, secret naming, DKG retrieval.
- `charts/dv-pod/TROUBLESHOOT.md` — named-pod, secret conflicts, DKG retry flow.
- `charts/dv-pod/values.yaml` — every tunable. Schema-validated (`values.schema.json`).
- `charts/dv-pod/values-examples/` — copy-pasteable scenarios.

When a user hits an issue, route to `TROUBLESHOOT.md` before reasoning from scratch.

### Verifying a deployed cluster

After every install, run the `charon alpha test` suites from one pod against its Charon:

```bash
kubectl exec -n dv-pod <charon-pod> -- charon alpha test <beacon|validator|peers|infra>
```

Use the global `test-a-dv-cluster` skill to parse output and resolve failures.

## The generic deployer: `obol-app`

`obol-app` is how the Obol Stack runs arbitrary Docker images under Helm. When a user says "deploy <service> on the Stack", this is the chart — not `dv-pod`. It provides workload, service, ingress, secrets, and resource-management primitives generic enough for any container.

For DV workloads keep using `dv-pod`; for everything else on the Stack (agents, RPCs, x402 endpoints, monitoring sidecars, etc.), reach for `obol-app`.

## Versioning

All Charon-based charts (`dv-pod`, `charon`, `charon-cluster`, `charon-relay`) ship with `appVersion: 1.9.3` (current Charon release at time of writing). Bump `charon.image.tag` in values, or let the chart track its pinned appVersion. Chart versions (SemVer) are independent of appVersion.

## Development

```bash
make init    # install pre-commit hooks
make docs    # regenerate each chart's README via helm-docs (pre-commit also does this)
make lint    # run helm/CT (chart-testing)
```

Don't edit chart READMEs by hand — they're generated from `README.md.gotmpl` + `values.yaml`. Edit the `.gotmpl` or values, then `make docs`.

Every chart (except `helios`) ships `values.schema.json` — validate values files against it before opening a PR.

## Supported networks for DV charts

Ethereum mainnet, hoodi, sepolia. Do **not** deploy against gnosis, chiado, or holesky (gnosis/chiado deprecated for Obol; holesky is dead).

For Stack charts (`obol-app`, `aztec-node`), additionally: Aztec, Base, Base-sepolia.

## Deployment best practices

Obol maintains a [deployment best practices guide](https://docs.obol.org/run-a-dv/prepare/deployment-best-practices) covering hardware sizing, networking, monitoring, backups, key handling, and operational hygiene. **Proactively offer to audit the user's setup against it** — walk through their values file, resource requests/limits, monitoring + alert routing, secret management, backup strategy for `charon-enr-private-key`/DKG artefacts, and network policies. Most operators benefit from a review (unset limits, missing PDBs, no pager wiring, weak RBAC) even on running clusters.

## Related products

- **`charon-distributed-validator-node`** — Docker Compose launcher; simpler, same DV outcome.
- **`obol-stack`** — the full Obol Stack binary; k3d-based local or public clusters that consume these charts underneath.
- **`lido-charon-distributed-validator-node`** — Lido CSM / stVault Compose variant.

## Key docs

- Obol docs: https://docs.obol.org/
- Charon CLI: https://docs.obol.org/docs/charon/charon-cli-reference
- DKG walkthrough: https://docs.obol.org/docs/start/dkg
- Activation: https://docs.obol.org/docs/next/start/activate
- Deployment best practices: https://docs.obol.org/run-a-dv/prepare/deployment-best-practices
- Obol Stack: https://obol.org/stack
- Launchpad: https://launchpad.obol.org
- Canonical agent index: https://obol.org/llms.txt (once live)
