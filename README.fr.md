<div align="center">

![Logo](assets/logo.svg)

[![License: MIT](https://img.shields.io/badge/License-MIT-7b2cbf?style=flat-square)](LICENSE)
[![GitHub Pages](https://img.shields.io/badge/Live-GitHub_Pages-00d4ff?style=flat-square&logo=github)](https://Tryboy869.github.io/gitsearch)

</div>

# 🔍 GITSEARCH

**Moteur de recherche sémantique GitHub** — Trouve ce que GitHub cache.

> *"GITSEARCH ne remplace pas GitHub. Il révèle ce que le moteur natif ne trouve pas : les repos cachés par un mauvais référencement, une description absente, ou des topics mal choisis."*

## Live

🌐 **[tryboy869.github.io/gitsearch](https://Tryboy869.github.io/gitsearch)**

## Comment ça marche

Trois stratégies de recherche parallèles fusionnées en un seul résultat :

| Stratégie | Endpoint | Ce qu'elle cherche |
|-----------|----------|-------------------|
| **A — Full-text** | `/search/repositories` | Nom + description + topics + README |
| **B — Name/Slug** | `/search/repositories` | Nom exact du repo (espaces → tirets) |
| **C — README** | `/search/code` | Phrase littérale dans les README (token requis) |

## Indexer votre repo

3 actions pour apparaître dans GITSEARCH :

1. Ajouter le topic `gitsearch` sur GitHub
2. Ajouter le badge dans votre README
3. Ajouter les tags sémantiques (invisibles dans le rendu GitHub)

## Licence

MIT © 2026 [Daouda Abdoul Anzize](https://tryboy869.github.io/daa) — Nexus Studio

<div align="center">

![Footer](assets/footer.svg)

</div>
