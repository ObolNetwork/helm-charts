#!/usr/bin/env bash
# Helm lint pre-commit hook
# Mimics the CI lint workflow logic from .github/workflows/release.yml

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SKIP_FILE="$REPO_ROOT/.github/helm-ci-values/skip-charts.txt"

cd "$REPO_ROOT"

# Read skip list
skip_list=()
if [[ -f "$SKIP_FILE" ]]; then
  while IFS= read -r line; do
    # Skip empty lines and comments
    [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue
    skip_list+=("$line")
  done < "$SKIP_FILE"
fi

echo "Linting Helm charts..."
failed_charts=()
linted_count=0
skipped_count=0

for chart_path in charts/*/; do
  chart=$(basename "$chart_path")
  values_file=".github/helm-ci-values/values-$chart.yaml"

  # Check if chart should be skipped
  skip_chart=false
  if [[ ${#skip_list[@]} -gt 0 ]]; then
    for skip in "${skip_list[@]}"; do
      if [[ "$chart" == "$skip" ]]; then
        skip_chart=true
        break
      fi
    done
  fi

  if $skip_chart; then
    echo "⊘ Skipping $chart (listed in skip-charts.txt)"
    skipped_count=$((skipped_count + 1))
    continue
  fi

  # Run helm lint and check exit code
  set +e
  if [[ -f "$values_file" ]]; then
    echo "→ Linting $chart with values file: $values_file"
    lint_output=$(helm lint "$chart_path" --values "$values_file" 2>&1)
    lint_exit=$?
  else
    echo "→ Linting $chart without custom values"
    lint_output=$(helm lint "$chart_path" 2>&1)
    lint_exit=$?
  fi
  set -e

  # Display output
  echo "$lint_output"

  # Check if lint failed (exit code 1) and if it's NOT just a dependency warning
  if [[ $lint_exit -ne 0 ]]; then
    # If it's only a dependency warning, don't fail
    if echo "$lint_output" | grep -q "chart metadata is missing these dependencies"; then
      echo "  ℹ  Ignoring dependency warning (local dependencies present)"
    else
      failed_charts+=("$chart")
    fi
  fi

  linted_count=$((linted_count + 1))
done

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Summary:"
echo "  Linted: $linted_count chart(s)"
echo "  Skipped: $skipped_count chart(s)"

if [[ ${#failed_charts[@]} -gt 0 ]]; then
  echo "  Failed: ${#failed_charts[@]} chart(s)"
  echo ""
  echo "Failed charts:"
  for chart in "${failed_charts[@]}"; do
    echo "  ✗ $chart"
  done
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  exit 1
fi

# Success if no failures (even if all charts were skipped)
if [[ $linted_count -eq 0 ]]; then
  echo "  All charts skipped (none to lint) ✓"
else
  echo "  All charts passed! ✓"
fi
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
exit 0
