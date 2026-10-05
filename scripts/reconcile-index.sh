#!/usr/bin/env bash
# Adds any chart GitHub release that is missing from the gh-pages index.yaml.
#
# chart-releaser only indexes charts packaged in the current run, so a release
# whose index update was lost (e.g. overwritten by a concurrent run) is never
# picked up again. This script heals that by diffing releases against the index.
#
# Usage: scripts/reconcile-index.sh <path-to-index.yaml>
# Requires: gh (authenticated), helm, yq. Modifies the index in place and exits 0
# whether or not anything changed; prints the added releases.
set -euo pipefail

INDEX="${1:?usage: $0 <path-to-index.yaml>}"
REPO="${GITHUB_REPOSITORY:-ObolNetwork/helm-charts}"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

indexed="$WORK/indexed.txt"
released="$WORK/released.txt"

# shellcheck disable=SC2016 # yq variables, not shell
yq e '.entries | to_entries | .[] | .key as $name | .value[] | $name + "-" + .version' "$INDEX" | sort -u > "$indexed"
gh release list -R "$REPO" --limit 1000 --exclude-drafts --json tagName --jq '.[].tagName' | sort -u > "$released"

missing="$(comm -23 "$released" "$indexed")"
if [[ -z "$missing" ]]; then
  echo "index.yaml is in sync with GitHub releases"
  exit 0
fi

for tag in $missing; do
  dir="$WORK/$tag"
  mkdir -p "$dir"
  if ! gh release download "$tag" -R "$REPO" -p "$tag.tgz" -D "$dir" 2>/dev/null; then
    echo "skip $tag: no $tag.tgz asset"
    continue
  fi
  helm repo index "$dir" \
    --url "https://github.com/$REPO/releases/download/$tag" \
    --merge "$INDEX"
  mv "$dir/index.yaml" "$INDEX"
  echo "added $tag"
done
