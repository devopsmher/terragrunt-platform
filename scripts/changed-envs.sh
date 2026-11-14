#!/usr/bin/env bash
# Prints a JSON array of live environments changed between BASE and HEAD, for a CI matrix:
#   [{"dir":"live/payments/dev","name":"payments-dev"}, ...]
# An environment is a live/<team>/<env> directory with a terragrunt.stack.hcl.
# A change to live/root.hcl affects every environment.
#
# Usage: scripts/changed-envs.sh <base commit>

set -euo pipefail

base="${1:?usage: changed-envs.sh <base commit>}"

# First push to a branch: GitHub sends an all-zero "before" commit.
if [[ "$base" =~ ^0+$ ]] || ! git cat-file -e "${base}^{commit}" 2>/dev/null; then
  base=$(git rev-parse HEAD~1)
fi

mapfile -t changed < <(git diff --name-only "$base" HEAD -- live/)

declare -A envs=()

if printf '%s\n' "${changed[@]}" | grep -qx 'live/root.hcl'; then
  while IFS= read -r file; do
    envs["$(dirname "$file")"]=1
  done < <(find live -name terragrunt.stack.hcl -not -path '*/.terragrunt-stack/*')
fi

for file in "${changed[@]}"; do
  dir=$(dirname "$file")
  while [[ "$dir" == live/* ]]; do
    if [[ -f "$dir/terragrunt.stack.hcl" ]]; then
      envs["$dir"]=1
      break
    fi
    dir=$(dirname "$dir")
  done
done

for dir in "${!envs[@]}"; do
  printf '%s\n' "$dir"
done | sort | jq -R 'select(length > 0) | {dir: ., name: (split("/") | "\(.[1])-\(.[2])")}' | jq -sc .
