#!/usr/bin/env bash
# Fails when a module, unit or stack source is not pinned to an exact version.
#
#   live/     every source has ?ref=, every literal version = "..." is a release tag (vX.Y.Z);
#   stacks/,
#   units/    every source is pinned with ?ref=${values.version}, passed down from the live repository;
#   modules/  every registry module has an exact version = "X.Y.Z" (no ~>, >= or ranges).
#
# Usage: scripts/check-pinned-refs.sh [repository root]

set -euo pipefail

root="${1:-.}"
failed=0

report() {
  printf '%s:%s: %s\n' "$1" "$2" "$3" >&2
  failed=1
}

# Our own files only: skip downloaded modules and generated stacks.
find_sources() {
  find "$root/$1" -type f -name "$2" \
    -not -path '*/.terraform/*' \
    -not -path '*/.terragrunt-cache/*' \
    -not -path '*/.terragrunt-stack/*'
}

# live/: sources need a ref; literal versions must be release tags.
while IFS= read -r file; do
  while IFS=: read -r line text; do
    [[ "$text" == *"?ref="* ]] || report "$file" "$line" "source without ?ref="
  done < <(grep -nE '^[[:space:]]*source[[:space:]]*=' "$file" || true)

  while IFS=: read -r line text; do
    # References such as local.version are checked where the literal is defined.
    [[ "$text" == *'"'* ]] || continue
    [[ "$text" =~ =[[:space:]]*\"v[0-9]+\.[0-9]+\.[0-9]+\" ]] ||
      report "$file" "$line" "version is not a release tag (vX.Y.Z)"
  done < <(grep -nE '^[[:space:]]*version[[:space:]]*=' "$file" || true)
done < <(find_sources live '*.hcl')

# stacks/ and units/: the version always comes from the live repository.
# shellcheck disable=SC2016 # ${values.version} is HCL, not a shell expansion
pinned='?ref=${values.version}"'
for dir in stacks units; do
  while IFS= read -r file; do
    while IFS=: read -r line text; do
      [[ "$text" == *"$pinned"* ]] || report "$file" "$line" "source is not pinned with ${pinned%\"}"
    done < <(grep -nE '^[[:space:]]*source[[:space:]]*=' "$file" || true)
  done < <(find_sources "$dir" '*.hcl')
done

# modules/: registry modules need an exact version.
while IFS= read -r file; do
  awk -v file="$file" '
    /^module[[:space:]]+"/ { in_module = 1; registry = 0; has_version = 0; start = NR }
    in_module && /^[[:space:]]+source[[:space:]]*=/ {
      if ($0 !~ /=[[:space:]]*"\./ && $0 !~ /::/) registry = 1
    }
    in_module && /^[[:space:]]+version[[:space:]]*=/ {
      has_version = 1
      if ($0 !~ /=[[:space:]]*"[0-9]+\.[0-9]+\.[0-9]+"[[:space:]]*$/) {
        printf "%s:%d: module version is not exact (X.Y.Z)\n", file, NR > "/dev/stderr"; bad = 1
      }
    }
    in_module && /^}/ {
      if (registry && !has_version) {
        printf "%s:%d: registry module without a version\n", file, start > "/dev/stderr"; bad = 1
      }
      in_module = 0
    }
    END { exit bad }
  ' "$file" || failed=1
done < <(find_sources modules '*.tf')

if ((failed)); then
  echo "pinning check failed: see the lines above" >&2
  exit 1
fi
echo "all sources are pinned"
