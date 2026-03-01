#!/usr/bin/env bash
# release.sh — Détecte la dernière version CHANGELOG → publie GitHub Release
set -euo pipefail

CHANGELOG="CHANGELOG.md"
[ -f "$CHANGELOG" ] || { echo "No CHANGELOG.md"; exit 1; }

# Extraire la première version ## [X.Y.Z]
LATEST=$(grep -m1 '^## \[' "$CHANGELOG" | sed 's/## \[//;s/\].*//' | tr -d '[:space:]')
[ -n "$LATEST" ] || { echo "No version in CHANGELOG"; exit 1; }

TAG="v${LATEST}"
echo "Detected version: $TAG"

# Vérifier si le tag existe déjà
if git tag --list | grep -q "^${TAG}$"; then
  echo "Tag $TAG already exists — skipping"
  exit 0
fi

# Extraire le body de la release (entre ## [LATEST] et le prochain ##)
BODY=$(awk "/^## \\[${LATEST}\\]/{found=1; next} found && /^## \\[/{exit} found{print}" "$CHANGELOG")

# Créer le tag
git config user.name "github-actions[bot]"
git config user.email "github-actions[bot]@users.noreply.github.com"
git tag "$TAG"
git push origin "$TAG"

# Créer la GitHub Release via API
curl -s -X POST \
  -H "Authorization: Bearer ${GITHUB_TOKEN}" \
  -H "Accept: application/vnd.github+json" \
  "https://api.github.com/repos/${GITHUB_REPOSITORY}/releases" \
  -d "$(jq -n --arg tag "$TAG" --arg body "$BODY" --argjson pre false \
    '{tag_name: $tag, name: ("🔍 GITSEARCH " + $tag), body: $body, draft: false, prerelease: $pre}')"

echo "✅ Release $TAG published"
