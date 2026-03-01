#!/usr/bin/env bash
set -euo pipefail
CHANGELOG="CHANGELOG.md"
[ -f "$CHANGELOG" ] || exit 1
LATEST=$(grep -m1 '^## \[' "$CHANGELOG" | sed 's/## \[//;s/\].*//' | tr -d '[:space:]')
[ -n "$LATEST" ] || exit 1
TAG="v${LATEST}"
git tag --list | grep -q "^${TAG}$" && echo "Tag $TAG exists" && exit 0
BODY=$(awk "/^## \\[${LATEST}\\]/{found=1;next} found && /^## \\[/{exit} found{print}" "$CHANGELOG")
git config user.name "github-actions[bot]"
git config user.email "github-actions[bot]@users.noreply.github.com"
git tag "$TAG" && git push origin "$TAG"
curl -s -X POST -H "Authorization: Bearer ${GITHUB_TOKEN}" \
  -H "Accept: application/vnd.github+json" \
  "https://api.github.com/repos/${GITHUB_REPOSITORY}/releases" \
  -d "$(jq -n --arg t "$TAG" --arg b "$BODY" '{tag_name:$t,name:("🔍 GITSEARCH "+$t),body:$b}')"
echo "✅ Release $TAG published"
