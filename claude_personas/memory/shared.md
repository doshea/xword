# Shared Project Board

Cross-persona handoffs. Keep this short — completed items get removed once deployed.

## Builder Pickup Rules

When a Builder picks up a plan:
1. **Timestamp it.** Add `Picked up by Builder at YYYY-MM-DD HH:MM` to the item.
2. **Check for conflicts.** If an item already has a pickup timestamp within the last
   15 minutes, **do not pick it up** — another Builder is already working on it.
3. After 15 minutes with no commit, the pickup expires and the item is available again.

## Pending Deploy

Items built but not yet deployed to production.

_(Nothing pending — all clear.)_

## Active / In Progress

### ✅ All recent work deployed (v547–v553)
- Backlog sprint (BEM rename, stats, NYT calendar) — v548
- Vendor Chart.js, CLAUDE.md refresh, session specs — v549
- Solve timer, next puzzle, profile N+1, FriendshipService, error pages — v550
- Visual design review (12 items: empty states, sticky footer, nav labels, error pages, etc.) — v553

### Remaining visual items (not addressed):
- Solve page toolbar icons cramped on mobile (minor)
- Admin panel table unstyled (low priority)

## Planner → Builder: Loading Feedback System (2026-03-04)

Users get no immediate feedback on clicks/submissions that trigger server calls. On Heroku
with cold boots, this means multi-second waits with zero acknowledgment.

### 4 Layers (in priority order):

**Layer 1 — Global Turbo navigation dimming** (~1 hr, HIGH impact)
- `turbo:click` listener adds `.xw-loading` class to clicked element (dim + spinner)
- Covers ALL puzzle card clicks, nav links, CTA buttons site-wide
- CSS: opacity 0.5, pointer-events none, `::after` spinner on puzzle cards
- Clean up on `turbo:before-render` / `turbo:load`
- Also add to `solution_choice.js` (programmatic `Turbo.visit` doesn't fire `turbo:click`)
- Files: `global.js`, `global.scss.erb`, `solution_choice.js`

**Layer 2 — Form `disable_with` on 16 buttons** (~45 min, MEDIUM, mechanical)
- Add `data: { disable_with: '...' }` to: Login, Signup (×2), Update Account, Reset Password,
  Publish Puzzle, Add/Accept/Decline Friend (×2 locations), Mark All Read, admin buttons
- 12 HAML files, same pattern used in 11 existing places
- **Test first:** verify Turbo 2.x uses `disable_with` not `turbo_submits_with`

**Layer 3 — Solve page toolbar button feedback** (~2 hrs, HIGH)
- New `.xw-btn--busy` class: dim + swap SVG icon for spinner
- Apply to Check ▾ parent button during check_cell/word/puzzle/completion + reveal/hint AJAX
- Save button: brief green pulse (`.xw-btn--saved`) on successful save
- `pointer-events: none` + `disabled` prevents double-clicks
- Re-enable in `$.ajax complete` callback (fires on success OR error)
- Files: `solve_funcs.js`, `crossword.scss.erb` or `_components.scss`

**Layer 4 — Edit page pattern search** (~10 min, LOW)
- Wire existing `loading_controller.js` to pattern search form
- Single line change in `edit.html.haml`

### Key infrastructure already available:
- `.xw-spinner` CSS class defined but **unused** (global.scss.erb:157)
- `@keyframes xw-spin` animation defined (global.scss.erb:167)
- `loading_controller.js` Stimulus (wired to 3 forms, ready for more)
- `prefers-reduced-motion` checks in place

### What NOT to change:
- Auto-save (silent by design), live search (fast enough), favorite toggle (already optimistic),
  delete actions (turbo_confirm is sufficient)

Full plan in `claude_personas/memory/plan.md`.

## Backlog

### Clue Suggestions from Phrase DB
Creator feature: suggest clues during puzzle editing based on 53K existing phrases. Query by
word content + text prefix. Infrastructure ready (Phrase model, Word model, pg_search).
Not yet planned in detail — next after timer/next-puzzle ships.
