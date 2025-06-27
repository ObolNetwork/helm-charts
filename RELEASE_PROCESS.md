# Helm Chart Release Process

This document outlines the steps for maintainers to release new versions of Helm charts in the ObolNetwork/helm-charts repository.

## 1. Pre-Release Checklist

Before starting the release process, ensure the following:

- [ ] All planned code changes, features, and bug fixes for the current release are merged into the `main` branch (or your primary development branch).
- [ ] All relevant documentation within the chart (e.g., `README.md`, comments in `values.yaml`) and general project documentation is up-to-date.
- [ ] All automated tests (linting, unit tests if applicable) are passing for the changes included in this release.

## 2. Dependency Update Procedure

For charts with external dependencies (e.g., `charon-cluster` depending on `erigon`, `lighthouse`), ensure they are using recent and stable versions.

1.  **Check for Latest Stable Dependency Versions:**
    *   Update your local Helm repository information:
        ```bash
        helm repo update
        ```
    *   Search for available versions of each key dependency. For example, for `erigon` and `lighthouse` from `ethereum-helm-charts`:
        ```bash
        helm search repo ethereum-helm-charts/erigon --versions
        helm search repo ethereum-helm-charts/lighthouse --versions
        ```
    *   Alternatively, browse [Artifact Hub](https://artifacthub.io/) for the dependency charts (e.g., search for `erigon` under the `ethpandaops` publisher).
2.  **Select Appropriate Versions:**
    *   Prioritize stable releases over release candidates or beta versions for your production releases.
    *   Review changelogs of the dependencies if available to understand potential impacts.
3.  **Update `Chart.yaml`:**
    *   Edit the `dependencies` section in the chart's `Chart.yaml` file (e.g., `charts/charon-cluster/Chart.yaml`) with the chosen new versions.
        ```yaml
        dependencies:
          - name: erigon
            version: "<new_erigon_version>" # Replace with actual version
            repository: "https://ethpandaops.github.io/ethereum-helm-charts"
            condition: erigon.enabled # Or other relevant condition
          - name: lighthouse
            version: "<new_lighthouse_version>" # Replace with actual version
            repository: "https://ethpandaops.github.io/ethereum-helm-charts"
            condition: lighthouse.enabled # Or other relevant condition
        ```
4.  **Update Chart Dependencies Locally:**
    *   Navigate to the chart's directory (e.g., `cd charts/charon-cluster`).
    *   Run:
        ```bash
        helm dependency update
        ```
        This will download the new dependency chart versions and update the `Chart.lock` file.
5.  **Commit Changes:**
    *   Commit the updated `Chart.yaml` and `Chart.lock` files to your Git repository.
        ```bash
        git add Chart.yaml Chart.lock
        git commit -m "feat(charon-cluster): Update erigon to vX.Y.Z and lighthouse to vA.B.C"
        ```

## 3. Testing

Thorough testing is crucial after any changes, especially dependency updates.

- [ ] **Lint the Chart:**
    ```bash
    helm lint charts/<chart-name>
    ```
- [ ] **Local Template Rendering Test (Optional but Recommended):**
    ```bash
    helm template charts/<chart-name> --values charts/<chart-name>/values.yaml
    ```
- [ ] **Local Deployment Test (e.g., using Minikube, Kind, Docker Desktop):**
    *   Install the chart and verify its functionality.
- [ ] **Staging Environment Deployment:**
    *   If available, deploy to a staging environment that mirrors production as closely as possible.
    *   Perform integration tests and verify core functionalities.

## 4. Versioning

Follow Semantic Versioning (SemVer - `MAJOR.MINOR.PATCH`) for your chart releases.

1.  **Determine the New Chart Version:**
    *   Increment `PATCH` for backward-compatible bug fixes.
    *   Increment `MINOR` for new backward-compatible functionality.
    *   Increment `MAJOR` for breaking changes.
2.  **Update `Chart.yaml`:**
    *   Modify the `version:` field in the chart's `Chart.yaml` (e.g., `charts/charon-cluster/Chart.yaml`) to the new version.
    *   If the application version bundled in the chart has changed, also update the `appVersion:` field. This `appVersion` does not strictly need to follow SemVer but should reflect the version of the main application being deployed (e.g., Charon version).
        ```yaml
        # In charts/<chart-name>/Chart.yaml
        version: "X.Y.Z"       # New chart version
        appVersion: "A.B.C"    # New application version, if changed
        ```
3.  **Commit Version Update:**
    ```bash
    git add charts/<chart-name>/Chart.yaml
    git commit -m "chore(<chart-name>): Bump version to vX.Y.Z"
    ```

## 5. Tagging and GitHub Release

1.  **Push Changes:** Ensure all changes, including version bumps, are pushed to the `main` branch.
2.  **Create a Git Tag:**
    *   Tags should generally match the chart name and its new version, e.g., `charon-cluster-vX.Y.Z`.
    *   For the `charon-cluster` chart at version `0.3.3`, the tag might be `charon-cluster-v0.3.3`.
    ```bash
    git tag -a <chart-name>-vX.Y.Z -m "Release <chart-name> vX.Y.Z"
    git push origin <chart-name>-vX.Y.Z
    ```
3.  **Create GitHub Release:**
    *   The `Release Charts` GitHub Action workflow (`.github/workflows/release.yml`) is typically triggered by pushing new tags that match a certain pattern (e.g., `*v*.*.*`). This workflow should handle packaging the chart and publishing it to GitHub Pages (which serves as the Helm repository) and Artifact Hub.
    *   Navigate to the "Releases" section of your GitHub repository.
    *   You might see a draft release created by the action, or you may need to create one based on the new tag.
    *   Write clear and concise release notes. Summarize key changes, new features, bug fixes, and any breaking changes or important upgrade notes.
    *   Publish the release.

## 6. Post-Release

- [ ] **Verify Chart Availability:**
    *   Check if the new chart version is available in your Helm repository (e.g., by running `helm repo update` and then `helm search repo <your-repo>/<chart-name> --versions`).
    *   Check [Artifact Hub](https://artifacthub.io/packages/search?org=obol) to ensure the new version is listed.
- [ ] **Announce the Release (if applicable):** Inform users through appropriate channels (e.g., Discord, Twitter, mailing list).
- [ ] **Monitor:** Keep an eye on any feedback or reported issues with the new release.

---

This process helps ensure consistent and reliable chart releases. Adapt these steps as necessary for your specific workflow and chart requirements.
