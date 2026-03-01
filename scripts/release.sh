#!/usr/bin/env bash
# ================================================================
#  GITSEARCH — release.sh
#  Détecte une nouvelle section dans CHANGELOG.md
#  et publie automatiquement une GitHub Release.
#
#  Dépendances : jq (préinstallé sur GitHub Actions runners)
#  Variables :
#    GH_TOKEN          — secrets.GITHUB_TOKEN (scope: contents:write)
#    GITHUB_REPOSITORY — auto-injecté par GitHub Actions
# ================================================================

set -euo pipefail

CHANGELOG="CHANGELOG.md"
TOKEN="${GH_TOKEN:-}"
REPO="${GITHUB_REPOSITORY:-Tryboy869/gitsearch}"

log()  { echo "[RELEASE] $*"; }
warn() { echo "[WARN]    $*"; }
die()  { echo "[ERROR]   $*" >&2; exit 1; }

# ── Vérifications ──────────────────────────────────────────────
[ -f "$CHANGELOG" ] || die "CHANGELOG.md introuvable."
[ -n "$TOKEN"     ] || die "GH_TOKEN non défini."
command -v jq >/dev/null 2>&1 || die "jq non disponible."

# ── Extraire la dernière version ───────────────────────────────
# Format attendu : ## [1.2.3] — 2026-03-01
LATEST_LINE=$(grep -m1 '^## \[' "$CHANGELOG" 2>/dev/null || true)
[ -n "$LATEST_LINE" ] || die "Aucune version trouvée dans CHANGELOG.md"

VERSION=$(echo "$LATEST_LINE" | sed 's/## \[\([^]]*\)\].*/\1/')
TAG="v${VERSION}"

log "Dernière version dans CHANGELOG : ${TAG}"

# ── Vérifier si le tag existe déjà ────────────────────────────
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" \
  -H "Authorization: token ${TOKEN}" \
  -H "Accept: application/vnd.github.v3+json" \
  "https://api.github.com/repos/${REPO}/git/ref/tags/${TAG}")

if [ "$HTTP_CODE" = "200" ]; then
  warn "Tag ${TAG} existe déjà — aucune nouvelle release."
  exit 0
fi

log "Tag ${TAG} absent — création de la release..."

# ── Extraire les notes depuis le CHANGELOG ────────────────────
NOTES=$(awk "
  /^## \[${VERSION}\]/ { found=1; next }
  found && /^## \[/    { exit }
  found                { print }
" "$CHANGELOG" | sed '/^[[:space:]]*$/d')

[ -n "$NOTES" ] || NOTES="Voir CHANGELOG.md pour les détails."

BODY="${NOTES}

---
*Release publiée automatiquement depuis CHANGELOG.md*"

# ── Créer la release via GitHub API ──────────────────────────
PAYLOAD=$(jq -n \
  --arg tag  "$TAG" \
  --arg name "GITSEARCH ${TAG}" \
  --arg body "$BODY" \
  '{
    tag_name:         $tag,
    target_commitish: "main",
    name:             $name,
    body:             $body,
    draft:            false,
    prerelease:       false
  }')

RESPONSE=$(curl -s -w "\n%{http_code}" \
  -X POST \
  -H "Authorization: token ${TOKEN}" \
  -H "Accept: application/vnd.github.v3+json" \
  -H "Content-Type: application/json" \
  "https://api.github.com/repos/${REPO}/releases" \
  -d "$PAYLOAD")

STATUS=$(echo "$RESPONSE" | tail -n1)
BODY_R=$(echo "$RESPONSE" | head -n -1)

if [ "$STATUS" = "201" ]; then
  URL=$(echo "$BODY_R" | jq -r '.html_url')
  log "✅ Release publiée : ${URL}"
else
  die "Échec release (HTTP ${STATUS}) : $(echo "$BODY_R" | jq -r '.message // "unknown error"')"
fi
