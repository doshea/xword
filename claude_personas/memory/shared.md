# Shared Project Board

Cross-persona handoffs. Keep this short — completed items get removed once deployed.

## Pending Deploy

Items built but not yet deployed to production.

_(Nothing pending — all clear.)_

## Active / In Progress

### Planner → Builder: Add Playwright MCP Server (Headless Screenshots)
One command: `claude mcp add --transport stdio playwright -- npx -y @playwright/mcp@latest --headless`
Then restart Claude Code. Pre-install browsers first: `npx playwright install chromium`.
Enables all personas to screenshot pages, navigate, log in, inspect DOM — fully headless (no focus stealing).
See planner memory for full details. Zero app code changes.

### ✅ Backlog Sprint — Complete

All 3 items from `claude_personas/memory/plan.md` done:

1. **Puzzle Card BEM Rename** — `.result-crossword` → `.xw-puzzle-card`, `.puzzle-tabs` → `.xw-puzzle-grid` (7 files renamed)
2. **Stats Page Modernization** — Chart.js v4 CDN + Stimulus controller (was already implemented)
3. **Test Suite Performance** — already closed out (test-prof + let_it_be adopted, 19 files converted)

### ✅ NYT Calendar — Smart Init + Year Navigation (Built, not deployed)
- Year nav buttons, smart prev/next, puzzle count, smart init, dataset fallback
- Commit `e721c27` — 3 files changed, 0 migrations

## Backlog

_(Empty — all items planned above.)_
