# Migration Guide for Helm Chart

After publishing the `charon-dkg-sidecar` image, update your Helm chart as follows:

## 1. Update values.yaml

Replace the current sidecar image configuration:

```yaml
charon:
  dkgSidecar:
    image:
      repository: ghcr.io/obolnetwork/charon-dkg-sidecar
      tag: v1.0.0  # Use the appropriate version tag
      pullPolicy: IfNotPresent
```

## 2. Remove embedded scripts

Delete the following files from the Helm chart:
- `charts/dv-pod/scripts/dkg-sidecar.js`
- `charts/dv-pod/scripts/dkg-sidecar.ts`
- `charts/dv-pod/scripts/package.json`
- `charts/dv-pod/scripts/pnpm-lock.yaml`
- `charts/dv-pod/scripts/tsconfig.json`
- `charts/dv-pod/scripts/README.md` (if it only relates to the sidecar)

## 3. Update StatefulSet template

In `templates/statefulset.yaml`, update the init container command:

```yaml
initContainers:
  - name: dkg-sidecar
    image: "{{ .Values.charon.dkgSidecar.image.repository }}:{{ .Values.charon.dkgSidecar.image.tag }}"
    imagePullPolicy: {{ .Values.charon.dkgSidecar.image.pullPolicy }}
    args:
      - "{{ .Values.charon.operatorAddress }}"
      - "/enr-from-job/enr.txt"
    # Remove the command section that referenced the local script
```

## 4. Update Dockerfile references

Remove any Dockerfile that was building the sidecar inline (like `charts/dv-pod/dkg-sidecar/Dockerfile`).

## 5. Update documentation

Update the chart's README.md to reference the external sidecar image repository for any development or debugging information.