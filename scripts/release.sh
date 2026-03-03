#!/usr/bin/env bash
set -euo pipefail
LATEST=$(grep -m1 '^## \[' CHANGELOG.md | sed 's/## \[//;s/\].*//' | tr -d '[:space:]')
[ -n "$LATEST" ] || exit 0
TAG="v${LATEST}"
git tag --list | grep -q "^${TAG}$" && exit 0
git config user.name "github-actions[bot]"
git config user.email "github-actions[bot]@users.noreply.github.com"
git tag "$TAG" && git push origin "$TAG"
curl -s -X POST -H "Authorization: Bearer ${GITHUB_TOKEN}" \
  -H "Accept: application/vnd.github+json" \
  "https://api.github.com/repos/${GITHUB_REPOSITORY}/releases" \
  -d "$(jq -n --arg t "$TAG" --arg b "" '{tag_name:$t,name:("🔍 GITSEARCH "+$t),body:$b}')"
