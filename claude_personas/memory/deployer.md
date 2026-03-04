# Deployer Memory

## Deploy History

### v529 — 2026-03-04
**Commits:** `3b7ee04`, `dbbea0b`
**Changes:**
- Bug fix: solve-mode row height jump (CSS `.letter` absolute positioning)
- Bug fix: focus skip in filled words (JS `in_directional_finished_word()` guard)
- CrosswordPublisher refactored into 5 private helpers
- Dead code deleted: `Crossword#publish!`, empty `charts.html.haml`
- Persona consolidation (7 → 3 roles)
- CLAUDE.md tech debt section updated

**Migration:** None
**Rollback:** `git revert dbbea0b 3b7ee04` (no data changes)
**Post-deploy:** Puma booted clean (2 workers, 3 threads each). Home/search/login all 200. `/crosswords` returns 404 (expected — requires auth or specific puzzle ID). Assets recompiled with new digests. Redis healthy (hit-rate=1).

**Visual verification:** ✅ CSS `.letter` positioning confirmed good on mobile/tablet by user (2026-03-04).

## Infrastructure Notes

- Heroku app: `crosswordcafe`
- Current release: v529
- Stack: Heroku-24, Ruby 3.4.8, Puma 7.2.0 (cluster: 2 workers, 3 threads)
- Redis: redis-silhouetted-63589 (1 active connection, 1.0 hit rate)
- Node.js warning on build (default v24.13.0 for ExecJS/Sprockets) — cosmetic, not actionable unless pinned via nodejs buildpack
- Deploy flow: `git push origin master && git push heroku master`

## Incidents & Resolutions
(none yet)
