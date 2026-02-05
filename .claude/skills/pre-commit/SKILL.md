---
name: pre-commit
description: Run before every commit on Helm chart changes. Regenerates README files via helm-docs and runs helm lint. Use this EVERY TIME you are about to commit changes that touch files under charts/.
---

# Pre-commit: Helm Docs + Lint

This repo has two pre-commit hooks that CI enforces (`lint.yml`):

1. **helm-docs** — regenerates `README.md` from `values.yaml` + `README.md.gotmpl`. If the README is stale, CI fails.
2. **helm-lint** — lints every chart (skipping those in `skip-charts.txt`).

## When to run

**Every time** you are about to create a commit that touches any file under `charts/`, run this skill first. The most common failure mode is editing `values.yaml` without regenerating the README.

## Steps

1. Run the pre-commit hooks on all files:

```bash
pre-commit run --all-files
```

2. If the exit code is non-zero **and** the output says "files were modified by this hook", that means helm-docs auto-fixed the READMEs. Stage the regenerated files and re-run:

```bash
git add charts/*/README.md
pre-commit run --all-files
```

3. If pre-commit still fails after the second run, inspect the error output and fix the underlying issue (e.g. invalid YAML, helm lint error).

4. Once both hooks pass, proceed with the commit — include any auto-generated README changes in the same commit or as a follow-up `docs:` commit.

## Important

- **Never** manually edit a chart's `README.md` if a `README.md.gotmpl` exists — your changes will be overwritten by helm-docs. Edit the `.gotmpl` template instead.
- The helm-docs hook matches files ending in `README.md.gotmpl`, `Chart.yaml`, `requirements.yaml`, or `values.yaml`.
- If `pre-commit` is not installed, install it with: `pip install pre-commit && pre-commit install`
- If the `helm-docs` Docker image is not cached, the first run may take a moment to pull it.
