# Helm Charts Repository

## Commit rules

**Before every commit that touches files under `charts/`**, you MUST run:

```bash
pre-commit run --all-files
```

If helm-docs modifies any `README.md` files, stage them (`git add charts/*/README.md`) and re-run until all hooks pass. Include the regenerated READMEs in your commit.

This is enforced by CI (`lint.yml`) and will block the PR if skipped.

## Chart conventions

- Each chart lives under `charts/<name>/`.
- `README.md` is auto-generated from `values.yaml` + `README.md.gotmpl` by [helm-docs](https://github.com/norwoodj/helm-docs). Never edit `README.md` directly when a `.gotmpl` exists.
- Charts skipped in CI integration tests are listed in `.github/helm-ci-values/skip-charts.txt`.
- CI values overrides live in `.github/helm-ci-values/values-<chart>.yaml`.

## Config validation

When writing Helm templates that generate application config files (e.g. `openclaw.json`), always verify the generated config keys against the application's actual schema. Many apps use strict validation (e.g. Zod `.strict()`) and will reject unknown keys at startup.
