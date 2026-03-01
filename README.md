<div align="center">

![Logo](assets/logo.svg)

[![License: MIT](https://img.shields.io/badge/License-MIT-7b2cbf?style=flat-square)](LICENSE)
[![GitHub Pages](https://img.shields.io/badge/Live-GitHub_Pages-00d4ff?style=flat-square&logo=github)](https://Tryboy869.github.io/gitsearch)
[![Zero Backend](https://img.shields.io/badge/Zero-Backend-ff006e?style=flat-square)](https://github.com/Tryboy869/gitsearch)
[![Vanilla JS](https://img.shields.io/badge/Vanilla-JS-fbbf24?style=flat-square&logo=javascript)](https://github.com/Tryboy869/gitsearch)

</div>

# 🔍 GITSEARCH

**Semantic GitHub Search Engine** — Find what GitHub hides.

> *"GITSEARCH doesn't replace GitHub. It reveals what the native engine can't find: repos hidden by poor SEO, missing descriptions, or wrong topics."*

## Live

🌐 **[tryboy869.github.io/gitsearch](https://Tryboy869.github.io/gitsearch)**

## How It Works

Three parallel search strategies fused into one result:

| Strategy | Endpoint | What it searches |
|----------|----------|-----------------|
| **A — Full-text** | `/search/repositories` | Name + description + topics + README index |
| **B — Name/Slug** | `/search/repositories` | Exact repo name (spaces → dashes) |
| **C — README Content** | `/search/code` | Literal phrase in README files (token required) |

Results are merged, deduplicated by `full_name`, then re-ranked by Stars / Recent / Oldest.

## Semantic Dictionary

30+ terms expanded automatically:
`machine learning` → `machine-learning, deep-learning, neural-network, ml`
`llm` → `llm, large-language-model, gpt, transformers`
`devops` → `devops, docker, kubernetes, terraform`
[...and 27 more]

## Zero Backend

GITSEARCH runs **entirely in your browser**. No server, no database, no login required.
- GitHub API called directly from the browser
- IndexedDB for local history + visited repos + token storage
- GitHub Pages for hosting (free, static)

## Index Your Repo

Add 3 things to your repo to appear in GITSEARCH:

1. Add topic `gitsearch` on GitHub (Settings → Topics)
2. Add badge in README:

```markdown
[![gitsearch](https://raw.githubusercontent.com/Tryboy869/gitsearch/main/assets/badges/badge-indexed.svg)](https://Tryboy869.github.io/gitsearch)
```

3. Add semantic tags (invisible in GitHub render):

```html
<!-- gitsearch: machine-learning, python, nlp, transformer -->
```

## Quick Start (local dev)

```bash
git clone https://github.com/Tryboy869/gitsearch
cd gitsearch
# Open index.html in browser — no build step needed
python -m http.server 8080
# → http://localhost:8080
```

## Structure

```
gitsearch/
├── index.html              ← Search engine (main page)
├── dashboard.html          ← Ecosystem metrics & trends
├── settings.html           ← GitHub token + preferences
├── assets/
│   ├── logo.svg            ← Animated SMIL logo
│   ├── footer.svg          ← Animated footer with code particles
│   ├── creator-card.svg    ← Creator card (700×240px)
│   └── badges/
│       ├── badge-indexed.svg   ← "indexed ✓" badge (210×28px)
│       └── badge-tags.svg      ← Semantic tags badge (340×28px)
├── scripts/
│   └── release.sh          ← Auto-release script
├── .github/workflows/
│   ├── pages.yml           ← GitHub Pages auto-deploy
│   ├── release.yml         ← CHANGELOG → GitHub Release
│   └── validate.yml        ← File validation
└── CHANGELOG.md • README.md • README.fr.md • LICENSE
```

## License

MIT © 2026 [Daouda Abdoul Anzize](https://tryboy869.github.io/daa) — Nexus Studio

<div align="center">

![Footer](assets/footer.svg)

</div>
