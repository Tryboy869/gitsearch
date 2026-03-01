# CHANGELOG

All notable changes to GITSEARCH are documented in this file.

Format: `## [VERSION] — YYYY-MM-DD`

---

## [1.0.0] — 2026-03-01

### 🚀 Initial Release

#### Added
- Semantic search engine with automatic query expansion to GitHub official topics
- Multi-domain sidebar with 13 technology domains
- Smart deduplication and tag normalization via semantic dictionary (50+ synonym mappings)
- GitHub API integration with optional token authentication (60 → 5000 req/h)
- Persistent search history and viewed repos via IndexedDB (zero backend)
- Dashboard with live ecosystem metrics: trending repos, language distribution, domain stats
- Settings page with GitHub OAuth token config, rate limit monitor, snippet generator
- Badge ecosystem: `badge-indexed.svg` + `badge-tags.svg` for README integration
- Animated SVG logo (magnifying glass + typewriter text reveal)
- Creator card SVG — Daouda Abdoul Anzize / Nexus Studio
- `<!-- gitsearch: tag1, tag2 -->` README convention for semantic tagging
- `topic:gitsearch` GitHub Topics integration for ecosystem membership
- GitHub Actions: auto-release from CHANGELOG detection
- Shell script: `release.sh` for automated release publishing
- Sitemap, robots.txt, SEO meta tags optimized
- WCAG 2.1 AA compliant — `prefers-reduced-motion` support on all SVG animations

---

<!-- RELEASE TEMPLATE — copy this block for new versions
## [X.Y.Z] — YYYY-MM-DD

### Added
-

### Changed
-

### Fixed
-

### Removed
-
-->
