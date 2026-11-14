#!/usr/bin/env bash
# Prints GitHub Actions outputs for one live environment directory (live/<team>/<env>):
#   name        <team>-<env>: the GitHub environment and the prefix of the CI roles
#   region      AWS region from env.hcl
#   plan_role   read-only role created by the account-baseline unit
#   apply_role  apply role created by the account-baseline unit
#
# Usage: scripts/env-info.sh live/<team>/<env> >> "$GITHUB_OUTPUT"

set -euo pipefail

dir="${1:?usage: env-info.sh live/<team>/<env>}"

read_local() {
  sed -nE "s/^[[:space:]]*$1[[:space:]]*=[[:space:]]*\"([^\"]+)\".*/\1/p" "$dir/env.hcl" | head -n 1
}

account_id=$(read_local account_id)
region=$(read_local region)

[[ "$account_id" =~ ^[0-9]{12}$ ]] || {
  echo "$dir/env.hcl: account_id must be 12 digits" >&2
  exit 1
}
[[ "$region" =~ ^[a-z]{2}(-[a-z]+)+-[0-9]$ ]] || {
  echo "$dir/env.hcl: region is missing or invalid" >&2
  exit 1
}

name="$(basename "$(dirname "$dir")")-$(basename "$dir")"

printf 'name=%s\n' "$name"
printf 'region=%s\n' "$region"
printf 'plan_role=arn:aws:iam::%s:role/%s-ci-plan\n' "$account_id" "$name"
printf 'apply_role=arn:aws:iam::%s:role/%s-ci-apply\n' "$account_id" "$name"
