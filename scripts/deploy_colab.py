"""
╔══════════════════════════════════════════════════════════════════╗
║           GITSEARCH — SCRIPT DE DÉPLOIEMENT COLAB               ║
║                                                                  ║
║  1. Installe les dépendances                                    ║
║  2. Valide le token GitHub                                       ║
║  3. Vous demande d'uploader le ZIP du projet                    ║
║  4. Crée le repo 'gitsearch' sur GitHub                         ║
║  5. Push tous les fichiers                                       ║
║  6. Active GitHub Pages                                          ║
║  7. Affiche l'URL finale                                         ║
╚══════════════════════════════════════════════════════════════════╝
"""

# ════════════════════════════════════════════════════════
#  ⚙️  CONFIGURATION — Remplacez votre token ici
# ════════════════════════════════════════════════════════

GITHUB_TOKEN = "VOTRE_TOKEN_ICI"   # ← Collez votre PAT GitHub (scope: repo, workflow)
REPO_NAME    = "gitsearch"          # ← Nom du repo public à créer
REPO_DESC    = "Semantic GitHub Search Engine — by Nexus Studio"
TOPICS       = ["github-search", "semantic-search", "open-source", "developer-tools", "vanilla-js", "github-pages"]

# ════════════════════════════════════════════════════════
#  INSTALLATION
# ════════════════════════════════════════════════════════

print("📦 Installation des dépendances...")
import subprocess, sys
subprocess.check_call([sys.executable, "-m", "pip", "install", "-q", "requests"])
print("✅ OK\n")

import os, io, json, zipfile, base64, time, requests
from pathlib import Path
from datetime import datetime

try:
    from google.colab import files as colab_files
    IN_COLAB = True
except ImportError:
    IN_COLAB = False

# ════════════════════════════════════════════════════════
#  VALIDATION TOKEN
# ════════════════════════════════════════════════════════

if GITHUB_TOKEN == "VOTRE_TOKEN_ICI" or not GITHUB_TOKEN.strip():
    raise ValueError("❌ Remplacez VOTRE_TOKEN_ICI par votre vrai token GitHub.")

AUTH_HEADERS = {
    "Authorization": f"token {GITHUB_TOKEN}",
    "Accept":        "application/vnd.github.v3+json",
}

print("🔐 Validation du token GitHub...")
user_resp = requests.get("https://api.github.com/user", headers=AUTH_HEADERS)
if user_resp.status_code != 200:
    raise ValueError(f"❌ Token invalide (HTTP {user_resp.status_code}). Vérifiez votre PAT.")

GITHUB_LOGIN = user_resp.json()["login"]
print(f"✅ Authentifié : @{GITHUB_LOGIN}\n")

# ════════════════════════════════════════════════════════
#  HELPERS API GITHUB (headers propres, sans conflits)
# ════════════════════════════════════════════════════════

def gh_get(endpoint, extra_accept=None):
    hdrs = dict(AUTH_HEADERS)
    if extra_accept:
        hdrs["Accept"] = extra_accept
    return requests.get(f"https://api.github.com{endpoint}", headers=hdrs)

def gh_post(endpoint, payload=None, extra_accept=None):
    hdrs = {**AUTH_HEADERS, "Content-Type": "application/json"}
    if extra_accept:
        hdrs["Accept"] = extra_accept
    return requests.post(f"https://api.github.com{endpoint}", headers=hdrs, json=payload or {})

def gh_put(endpoint, payload=None):
    hdrs = {**AUTH_HEADERS, "Content-Type": "application/json"}
    return requests.put(f"https://api.github.com{endpoint}", headers=hdrs, json=payload or {})

def get_sha(repo, path):
    r = gh_get(f"/repos/{GITHUB_LOGIN}/{repo}/contents/{path}")
    return r.json().get("sha") if r.status_code == 200 else None

def push_file(repo, path, content_bytes, message):
    encoded = base64.b64encode(content_bytes).decode("utf-8")
    sha     = get_sha(repo, path)
    body    = {"message": message, "content": encoded}
    if sha:
        body["sha"] = sha
    r = gh_put(f"/repos/{GITHUB_LOGIN}/{repo}/contents/{path}", body)
    if r.status_code in [200, 201]:
        return True
    print(f"   ⚠️  '{path}': {r.status_code} — {r.text[:100]}")
    return False

def push_directory(repo, local_dir, verbose=True):
    local_dir = Path(local_dir)
    skip      = {'.git', '.DS_Store', '__pycache__', 'Thumbs.db'}
    pushed, failed = 0, 0

    for fp in sorted(local_dir.rglob("*")):
        if fp.is_dir():
            continue
        if any(part in skip for part in fp.parts):
            continue

        rel = fp.relative_to(local_dir).as_posix()
        try:
            ok = push_file(repo, rel, fp.read_bytes(), f"init: add {rel}")
            if ok:
                pushed += 1
                if verbose:
                    print(f"   📄 {rel}")
            else:
                failed += 1
            time.sleep(0.3)
        except Exception as e:
            print(f"   ❌ {rel}: {e}")
            failed += 1

    return pushed, failed

# ════════════════════════════════════════════════════════
#  UPLOAD DU ZIP
# ════════════════════════════════════════════════════════

print("📁 Sélection du fichier ZIP GITSEARCH...")
print("   → Un bouton de sélection va apparaître ci-dessous.\n")

if IN_COLAB:
    uploaded     = colab_files.upload()
    if not uploaded:
        raise ValueError("❌ Aucun fichier uploadé.")
    zip_filename = list(uploaded.keys())[0]
    zip_bytes    = uploaded[zip_filename]
    print(f"\n✅ Fichier reçu : {zip_filename} ({len(zip_bytes):,} octets)\n")
else:
    # Fallback local
    candidates = list(Path(".").glob("gitsearch*.zip")) + list(Path(".").glob("*.zip"))
    if not candidates:
        raise FileNotFoundError("❌ Aucun fichier ZIP trouvé dans le dossier courant.")
    zip_filename = str(candidates[0])
    with open(zip_filename, "rb") as f:
        zip_bytes = f.read()
    print(f"✅ Fichier local : {zip_filename}\n")

# ════════════════════════════════════════════════════════
#  EXTRACTION
# ════════════════════════════════════════════════════════

EXTRACT_DIR = Path("/tmp/gitsearch_deploy")
EXTRACT_DIR.mkdir(parents=True, exist_ok=True)

print("📂 Extraction du ZIP...")
with zipfile.ZipFile(io.BytesIO(zip_bytes if isinstance(zip_bytes, bytes) else bytes(zip_bytes)), 'r') as z:
    z.extractall(EXTRACT_DIR)

contents = list(EXTRACT_DIR.iterdir())
if len(contents) == 1 and contents[0].is_dir():
    PROJECT_DIR = contents[0]
else:
    PROJECT_DIR = EXTRACT_DIR

print(f"✅ Extraction terminée : {PROJECT_DIR}\n")
print(f"   Fichiers détectés : {sum(1 for _ in PROJECT_DIR.rglob('*') if _.is_file())}")

# ════════════════════════════════════════════════════════
#  CRÉATION DU REPO GITHUB
# ════════════════════════════════════════════════════════

print(f"\n{'='*60}")
print(f"🌍 CRÉATION DU REPO PUBLIC : {REPO_NAME}")
print(f"{'='*60}")

create_resp = gh_post("/user/repos", {
    "name":        REPO_NAME,
    "description": REPO_DESC,
    "private":     False,
    "auto_init":   True,
    "homepage":    f"https://{GITHUB_LOGIN}.github.io/{REPO_NAME}",
})

if create_resp.status_code == 201:
    print(f"   ✅ Repo '{REPO_NAME}' créé avec succès.")
elif create_resp.status_code == 422:
    print(f"   ℹ️  Repo '{REPO_NAME}' existait déjà — on va mettre à jour les fichiers.")
else:
    raise ValueError(f"❌ Erreur création repo: {create_resp.status_code} {create_resp.text[:200]}")

time.sleep(2)

# ════════════════════════════════════════════════════════
#  PUSH DES FICHIERS
# ════════════════════════════════════════════════════════

print(f"\n📤 Push des fichiers vers '{REPO_NAME}'...")
pushed, failed = push_directory(REPO_NAME, PROJECT_DIR, verbose=True)
print(f"\n   ✅ {pushed} fichiers pushés, {failed} erreurs.")

# ════════════════════════════════════════════════════════
#  TOPICS DU REPO
# ════════════════════════════════════════════════════════

print("\n🏷 Ajout des topics...")
topics_resp = gh_put(
    f"/repos/{GITHUB_LOGIN}/{REPO_NAME}/topics",
    {"names": TOPICS}
)
print(f"   {'✅' if topics_resp.status_code == 200 else '⚠️ '} Topics : {', '.join(TOPICS)}")

# ════════════════════════════════════════════════════════
#  ACTIVATION GITHUB PAGES
# ════════════════════════════════════════════════════════

print("\n🌐 Activation GitHub Pages...")
time.sleep(2)

pages_resp = gh_post(
    f"/repos/{GITHUB_LOGIN}/{REPO_NAME}/pages",
    payload={"source": {"branch": "main", "path": "/"}},
    extra_accept="application/vnd.github.switcheroo-preview+json"
)

if pages_resp.status_code in [200, 201]:
    print("   ✅ GitHub Pages activé.")
elif pages_resp.status_code == 409:
    print("   ℹ️  GitHub Pages était déjà activé.")
else:
    print(f"   ⚠️  Pages: {pages_resp.status_code} — {pages_resp.text[:150]}")
    print("   → Activez manuellement : Settings → Pages → Branch: main → Save")

# ════════════════════════════════════════════════════════
#  RÉSUMÉ FINAL
# ════════════════════════════════════════════════════════

pages_url = f"https://{GITHUB_LOGIN}.github.io/{REPO_NAME}"
repo_url  = f"https://github.com/{GITHUB_LOGIN}/{REPO_NAME}"

print(f"\n{'='*60}")
print("🎉 DÉPLOIEMENT TERMINÉ")
print(f"{'='*60}")
print(f"""
📦 Repo GitHub  : {repo_url}
🌐 GitHub Pages : {pages_url}
   (1-2 min pour que Pages s'active la première fois)

🔍 URLs des pages :
   Search    : {pages_url}/
   Dashboard : {pages_url}/dashboard.html
   Settings  : {pages_url}/settings.html

📋 PROCHAINES ÉTAPES :
   1. Vérifier que GitHub Pages est actif (Settings → Pages)
   2. Aller dans Settings pour configurer votre token GitHub
   3. Indexez votre premier repo avec les badges !

✦ GITSEARCH est en ligne !
""")
