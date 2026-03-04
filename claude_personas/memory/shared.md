# Shared Project Board

Cross-persona handoffs. Keep this short — completed items get removed once deployed.

## Pending Deploy

Items built but not yet deployed to production.

### Reveal Hints — Persistent Black Tabs + Hint Word
- Migration: `add_hints_used_to_solutions` (integer, default 0) + `add_revealed_indices_to_solutions` (text/JSON, default '[]')
- Revealed cells show black tab, persist across reloads
- "Reveal Letter" + "Hint Word" in Check dropdown
- Win modal shows "💡 N hints used"

### Fix Clue UTF-8 Double-Encoding
- Migration: `fix_double_encoded_clues` — reverses Ã-signature double-encoding in existing clues
- Encoding guard in `Clue#strip_tags` + `NytPuzzleFetcher.ensure_utf8`

### Homepage "Load More" Pagination
- `POST /home/load_more` — Turbo Stream load-more for all 3 tabs
- Dead `batch` endpoint/route/view deleted

### Welcome Page Rebuild
- Stimulus chalkboard controller replaces jQuery slider
- BEM + design tokens + accessibility (sr-only labels, ARIA, autocomplete)
- Mobile: dark container, show/hide panels
- Deleted: `welcome.js.erb`, `_chalkboard.html.haml`, `layouts.scss.erb`, `_dimensions.scss`

### Edit Page: Void/Empty Cell Swap Fix
- Controller + JS fix for integer `0` vs string `"0"` void cells
- Run `bundle exec rails repair:void_cells` in production after deploy

### Sleeker Footer
- Transparent colophon strip (CSS + HAML already aligned)

### Other Deployed Items Needing Verification
- Admin test tools (Fake Win, Reveal Puzzle, Clear Puzzle, Flash Cascade)
- Notification system + friend requests + puzzle invites
- Cell check flash cascade
- Solve timer + next puzzle on win modal
- Default scope removal (random/search/admin sort fixes)

## Active / In Progress

### Planner → Builder: NYT Page Day-of-Week Tabs + Calendar View
Full plan in `claude_personas/memory/plan.md`. 6 files, 0 migrations. Key points:
- Controller: `.to_a` before `.group_by` (single query). Set all ivars on nil-user early return.
- View: nyt-view controller (toggle) wraps tabs controller (7 day tabs). No nesting conflict.
- Calendar: Stimulus controller reads JSON data attribute. **Test values API first** — fallback
  to `this.element.dataset` if not supported.
- CSS: `.nyt-view-panel` visibility rules (missing from original plan) are included.
- Specs: expand existing `GET /nytimes` block in `spec/requests/pages_spec.rb`.

## Backlog

### Puzzle Card BEM Rename (Low Priority)
Rename `.crossword-tab` → `.xw-puzzle-card` with BEM modifiers. Deferred — low impact, many files.
