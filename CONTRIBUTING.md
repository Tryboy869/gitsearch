# Contributing to GITSEARCH

Merci de vouloir contribuer à GITSEARCH — le moteur de recherche sémantique GitHub.

---

## Comment contribuer

### 1. Indexer votre repo (contribution la plus simple)

Ajoutez le badge GITSEARCH dans votre `README.md` :

```markdown
[![gitsearch](https://raw.githubusercontent.com/Tryboy869/gitsearch/main/assets/badges/badge-indexed.svg)](https://tryboy869.github.io/gitsearch)
<!-- gitsearch: tag1, tag2, tag3 -->
```

Puis ajoutez le topic `gitsearch` sur votre repo GitHub.

---

### 2. Améliorer le dictionnaire sémantique

Le fichier principal est `index.html` — section `SEMANTIC_MAP`.

Exemple de contribution :

```js
// Avant
'async': ['async', 'asynchronous', 'concurrency'],

// Après (ajout de termes pertinents)
'async': ['async', 'asynchronous', 'concurrency', 'event-driven', 'reactive', 'tokio', 'asyncio'],
```

Ouvrez une Pull Request avec vos ajouts.

---

### 3. Ajouter des domaines

Dans `index.html`, section `DOMAINS` :

```js
{ label: 'Votre Domaine', topics: ['topic1', 'topic2', 'topic3', 'topic4'] },
```

Les topics doivent être des **GitHub Topics officiels** valides.

---

### 4. Bug reports & Feature requests

Ouvrez une [Issue](https://github.com/Tryboy869/gitsearch/issues) avec :
- Description claire du problème ou de la feature
- Étapes pour reproduire (si bug)
- Screenshot si pertinent

---

## Standards

- **Pas de dépendances npm** — le projet est 100% vanilla JS + CDN Tailwind
- **Pas de backend** — tout fonctionne en client-side
- **WCAG 2.1 AA** — les SVG doivent supporter `prefers-reduced-motion`
- **SVG < 50 KB** pour les badges, < 150 KB pour les animations larges

---

## Code of Conduct

Voir [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md).

---

*Made with ❤️ by [Nexus Studio](https://github.com/Tryboy869)*
