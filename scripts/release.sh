#!/usr/bin/env bash
# =============================================================
#  GITSEARCH — release.sh
#  Détecte une nouvelle version dans CHANGELOG.md et publie
#  automatiquement une GitHub Release via l'API.
#
#  Utilisé par : .github/workflows/release.yml
#  Variables requises (GitHub Actions secrets) :
#    GH_TOKEN  — Personal Access Token (scope: repo)
#    REPO      — owner/repo (ex: Tryboy869/gitsearch)
# =============================================================

set -euo pipefail

CHANGELOG="CHANGELOG.md"
TOKEN="${GH_TOKEN:-}"
REPO="${GITHUB_REPOSITORY:-Tryboy869/gitsearch}"

# ── Couleurs (désactivées en CI sans TTY) ──
if [ -t 1 ]; then
  GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; NC='\033[0m'
else
  GREEN=''; YELLOW=''; RED=''; NC=''
fi

log()  { echo -e "${GREEN}[RELEASE]${NC} $*"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $*"; }
err()  { echo -e "${RED}[ERROR]${NC} $*" >&2; exit 1; }

# ── Vérifications ──
[ -f "$CHANGELOG" ] || err "CHANGELOG.md introuvable."
[ -n "$TOKEN"     ] || err "GH_TOKEN non défini."

# ── Extraire la dernière version du CHANGELOG ──
# Format attendu : ## [1.2.3] — 2026-03-01
LATEST_LINE=$(grep -m1 '^## \[' "$CHANGELOG" || true)
[ -n "$LATEST_LINE" ] || err "Aucune version trouvée dans CHANGELOG.md"

VERSION=$(echo "$LATEST_LINE" | grep -oP '\[\K[^\]]+')
DATE=$(echo "$LATEST_LINE" | grep -oP '\d{4}-\d{2}-\d{2}' || echo "")
TAG="v${VERSION}"

log "Dernière version détectée : ${TAG} (${DATE})"

# ── Vérifier si le tag existe déjà sur GitHub ──
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" \
  -H "Authorization: token ${TOKEN}" \
  -H "Accept: application/vnd.github.v3+json" \
  "https://api.github.com/repos/${REPO}/git/ref/tags/${TAG}")

if [ "$HTTP_CODE" = "200" ]; then
  warn "Tag ${TAG} existe déjà. Aucune release à publier."
  exit 0
fi

log "Tag ${TAG} inexistant. Création de la release..."

# ── Extraire les notes de release depuis le CHANGELOG ──
# Tout ce qui est entre la première ligne ## et la suivante
NOTES=$(awk "/^## \[${VERSION}\]/{found=1; next} found && /^## \[/{exit} found{print}" "$CHANGELOG")

if [ -z "$NOTES" ]; then
  NOTES="See CHANGELOG.md for details."
fi

# ── Préparer le body JSON ──
BODY=$(printf '%s\n\n---\n*Released automatically from CHANGELOG.md*' "$NOTES")

# Échapper pour JSON
JSON_BODY=$(echo "$BODY" | python3 -c "import sys,json; print(json.dumps(sys.stdin.read()))")

# ── Créer la GitHub Release via API ──
RESPONSE=$(curl -s -w "\n%{http_code}" \
  -X POST \
  -H "Authorization: token ${TOKEN}" \
  -H "Accept: application/vnd.github.v3+json" \
  -H "Content-Type: application/json" \
  "https://api.github.com/repos/${REPO}/releases" \
  -d "{
    \"tag_name\": \"${TAG}\",
    \"target_commitish\": \"main\",
    \"name\": \"GITSEARCH ${TAG}\",
    \"body\": ${JSON_BODY},
    \"draft\": false,
    \"prerelease\": false
  }")

HTTP_STATUS=$(echo "$RESPONSE" | tail -n1)
RESPONSE_BODY=$(echo "$RESPONSE" | head -n-1)

if [ "$HTTP_STATUS" = "201" ]; then
  RELEASE_URL=$(echo "$RESPONSE_BODY" | python3 -c "import sys,json; print(json.load(sys.stdin)['html_url'])")
  log "✅ Release publiée avec succès !"
  log "URL : ${RELEASE_URL}"
else
  err "Échec de la release (HTTP ${HTTP_STATUS}): ${RESPONSE_BODY}"
fi
