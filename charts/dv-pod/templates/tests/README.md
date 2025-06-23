# Chart tests

This directory contains Helm test hooks used with the `charon-cluster` chart.
Each test is conditionally rendered based on chart values.

## ENR tests

- **test-default-enr-generation.yaml**
  - Rendered when `charon.enr.generate.enabled` is true and neither
    `charon.enr.privateKey` nor `charon.enr.existingSecret.name` are set.
  - Waits for the ENR generation Job to complete and verifies the created
    secret contains a private key and public ENR.

- **test-provided-enr.yaml**
  - Rendered when `charon.enr.privateKey` is provided.
  - Ensures the generated secret contains the expected private key and that
    the ENR generation job completes successfully.

- **test-existing-enr-secret.yaml**
  - Rendered when `charon.enr.existingSecret.name` is set.
  - Confirms no ENR generation Job was created and verifies that the running
    Charon pod mounts the specified secret.

## DKG sidecar tests

- **test-dkg-mock-api.yaml**
  - Deploys a mock Obol API server used by sidecar tests.
  - Enabled when `tests.dkgSidecar.enabled` is true.

- **test-dkg-sidecar-fresh-state.yaml**
  - Runs the sidecar init container against the mock API configured in a
    `FRESH` state to validate polling behaviour.
  - Enabled when `tests.dkgSidecar.freshState.enabled` is true.

## RBAC

- **test-rbac.yaml**
  - Creates the service account and RBAC permissions used by the other test
    pods.
