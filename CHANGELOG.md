# Changelog — GITSEARCH

## [2.0.0] — 2026-03-01

### ✦ Rebuild — Dojutsu Context Engine v1.0

- Rebuild complet avec ContextEngine (mémoire RAM partagée inter-fichiers)
- Cohérence visuelle garantie entre index/dashboard/settings (dark theme #0a0e1a)
- Injection segmentée selon context window Kimi (131k tokens)
- Compression RAG décisionnelle (150 mots/fichier)
- Validation cohérence automatique + autocorrection violations
- Triple stratégie de recherche A/B/C inchangée
- IndexedDB gitsearch_v1 partagée entre les 3 pages
