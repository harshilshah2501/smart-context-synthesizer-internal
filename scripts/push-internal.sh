#!/usr/bin/env bash
# Push internal main branch to the private GitHub repository.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO_ROOT"

if ! git remote get-url internal >/dev/null 2>&1; then
  echo "Missing remote: internal (private repo)" >&2
  echo "  git remote add internal https://github.com/harshilshah2501/smart-context-synthesizer-internal.git" >&2
  exit 1
fi

CURRENT="$(git branch --show-current)"
if [[ "$CURRENT" != "main" ]]; then
  echo "Switching to main..."
  git checkout main
fi

echo "Pushing main → internal/main ($(git rev-parse --short HEAD))"
git push internal main

echo "Done."
