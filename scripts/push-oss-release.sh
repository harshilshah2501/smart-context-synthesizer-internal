#!/usr/bin/env bash
# Push curated OSS branch to the public GitHub repository.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO_ROOT"

if ! git remote get-url origin >/dev/null 2>&1; then
  echo "Missing remote: origin (public repo)" >&2
  exit 1
fi

CURRENT="$(git branch --show-current)"
if [[ "$CURRENT" != "public" ]]; then
  echo "Switching to public branch..."
  git checkout public
fi

echo "Pushing public → origin/main ($(git rev-parse --short HEAD))"
git push origin public:main

echo "Done. Public repo updated."
echo "Return to internal work: git checkout main"
