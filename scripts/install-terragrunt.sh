#!/usr/bin/env bash
# Installs a pinned Terragrunt release on a Linux CI runner and verifies its SHA-256 checksum.
#
# Usage: scripts/install-terragrunt.sh <version>, for example 1.2.1

set -euo pipefail

version="${1:?usage: install-terragrunt.sh <version>}"
asset="terragrunt_linux_amd64"
base="https://github.com/gruntwork-io/terragrunt/releases/download/v${version}"

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

curl -fsSL -o "$tmp/$asset" "$base/$asset"
curl -fsSL -o "$tmp/SHA256SUMS" "$base/SHA256SUMS"
(cd "$tmp" && grep " ${asset}\$" SHA256SUMS | sha256sum -c -)

sudo install -m 0755 "$tmp/$asset" /usr/local/bin/terragrunt
terragrunt --version
