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

### ✅ All recent work deployed (v547–v555)
- Backlog sprint (BEM rename, stats, NYT calendar) — v548
- Vendor Chart.js, CLAUDE.md refresh, session specs — v549
- Solve timer, next puzzle, profile N+1, FriendshipService, error pages — v550
- Visual design review (12 items: empty states, sticky footer, nav labels, error pages, etc.) — v554
- Loading feedback system (4 layers: nav dimming, disable_with, solve toolbar, pattern search) — v555

### Planner → Builder: Home Page Pixel-Perfect Review (2026-03-04)

**Scope:** Desktop (1280×900), tablet (768×1024), mobile (375×812). All 3 tabs with 15 crosswords.
**Screenshots:** `screenshots/hp-01-*` through `hp-05-*`.

**Must-fix (2):**

1. **Duplicate conflicting puzzle card CSS** — Two `.xw-puzzle-card` rule sets in `_components.scss`:
   - Lines 219-264: nested selectors (high specificity) — title=`--font-display`, byline=`--font-ui` 11px, border-radius=`--radius-lg` (via @extend .xw-card)
   - Lines 861-919: standalone selectors — title=`--font-body`, byline=`--font-body` italic, border-radius=`--radius-md`
   - Nested set wins. Standalone set is dead code that will confuse future editors.
   - **Fix:** Delete lines 861-919 OR merge desired styles into lines 219-264. Decide on title font: Playfair Display (editorial, less legible at 16px) or Lora (body, designed for small sizes). Decide on byline: DM Sans plain or Lora italic.
   - Recommendation: Lora semibold for title (matches body font, reads better at small size), Lora italic for byline (editorial warmth), keep DM Sans for dims.

2. **HR uses browser-default 3D inset border** — `hr.xw-hr--flush` renders with `border: 1px inset` (grooved 3D effect). Creates double-line artifact with adjacent tabs border-bottom.
   - **Fix:** Add to global reset or `.xw-hr--flush`: `border: none; border-top: 1px solid var(--color-border);`
   - OR: remove the `<hr>` entirely from `home.html.haml` — the `.xw-tabs__nav` border-bottom already provides visual separation.

**Should-fix (4):**

3. **12-column grid inside 243px card** — Each `.xw-puzzle-card` uses `.xw-grid` (12-col CSS Grid with 16px gaps) internally. Columns compute to 5.4px each. Layout works by accident via `.xw-lg-4` / `.xw-lg-8`. Fragile — any gap/width change breaks it.
   - **Fix:** Replace inner `.xw-grid` + column classes with simple flexbox in `_crossword_tab.html.haml`. E.g., `.xw-puzzle-card__inner { display: flex; align-items: center; }`.

4. **H1 uses browser-default margins (21.44px)** — Not on design token scale. Combined with `search.scss.erb` padding-top (24px), creates 45px effective top spacing vs 32px bottom padding. Top-heavy.
   - **Fix:** `h1 { margin: var(--space-6) 0 var(--space-4) 0; }` scoped to home page, or add `margin-top: 0` to the h1 inside the container.

5. **"Solved Puzzles (2)" truncated on mobile** — Tab label cut off at "Solved P..." at 375px. Scrollable tabs work but no visual scroll affordance (scrollbar hidden).
   - **Fix options:** (a) Abbreviate label to "Solved (2)" at mobile, (b) add fade/shadow on right edge of `.xw-tabs__nav` to indicate scrollable content, (c) reduce tab padding on mobile.

6. **Thumbnail overflow** — 75×75px image sits in a grid cell that computes to 69.7px wide. Image overflows container on both sides. `.xw-card`'s `overflow: hidden` clips it visually, but the layout is structurally wrong.
   - **Fix:** Addressed by item 3 (replacing inner grid with flexbox). Give thumb container explicit `width: 75px; flex-shrink: 0;`.

**Suggestions (4):**

7. Tab icons stacked above text → tall tab bar (~56px). Inline layout (icon left, text right) would be more compact. Low priority.
8. Byline and dims both 11px DM Sans muted — visually identical weight. Italic byline (from line 901 intent) would improve differentiation.
9. Card hover effect subtle (bg-color only). `.xw-card` base has `translateY(-1px)` + `shadow-md` on hover but `.xw-puzzle-card` at line 867 overrides to weaker `shadow-sm`. Remove the override to get the lift effect.
10. Sparse tab content (e.g., Solved with 2 cards) leaves large wood-grain gap before footer. Consider min-height on tab panel.

### Remaining visual items (not addressed):
- Solve page toolbar icons cramped on mobile (minor)
- Admin panel table unstyled (low priority)

## Backlog

### Clue Suggestions from Phrase DB
Creator feature: suggest clues during puzzle editing based on 53K existing phrases. Query by
word content + text prefix. Infrastructure ready (Phrase model, Word model, pg_search).
Not yet planned in detail — next after timer/next-puzzle ships.
