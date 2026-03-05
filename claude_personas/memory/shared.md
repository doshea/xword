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

### Edit Page Save Bugs — CRITICAL (Built 2026-03-04)
- **Bug 1 fixed:** `update_letters` now correctly distinguishes voids (`nil`), empty cells (`""`), and letters
- **Bug 2 fixed:** `save_puzzle()` now calls `e.preventDefault()` to stop Turbo page destroy
- **Save button right-aligned** via `margin-left: auto` on `#puzzle-controls`
- **4 regression specs added** in `spec/requests/unpublished_crosswords_spec.rb`
- **2 controller specs updated** to expect corrected behavior
- **Data repair task added:** `bundle exec rails repair:diagnose_void_corruption` flags UCWs with >60% voids
- **Also run:** `bundle exec rails repair:void_cells` to fix "0" string corruption
- **Builder → Deployer:** No migration needed. Run both repair rake tasks after deploy.

### Account Settings Rebuild (Built 2026-03-05)
- **Single scrollable page** replaces 4-tab layout (2 were placeholders)
- **3 sections:** Profile (+ email/username editing), Notifications (5 JSONB toggles), Account (password + delete)
- **Account deletion:** Anonymize pattern — PII stripped, record kept, all FKs valid. "[Deleted Account]" display.
- **10 views updated** with `deleted?` guards (comments, replies, bylines, admin tables, search, profile)
- **92 specs green** (model: 6 new method tests, request: email/username/prefs/delete/deleted-user, service: mute check)
- **Builder → Deployer:** Migration adds 2 columns (`notification_preferences` JSONB, `deleted_at` datetime). Run `rails db:migrate`. No data repair needed.

## Active / In Progress

### ✅ All recent work deployed (v547–v555)
- Backlog sprint (BEM rename, stats, NYT calendar) — v548
- Vendor Chart.js, CLAUDE.md refresh, session specs — v549
- Solve timer, next puzzle, profile N+1, FriendshipService, error pages — v550
- Visual design review (12 items: empty states, sticky footer, nav labels, error pages, etc.) — v554
- Loading feedback system (4 layers: nav dimming, disable_with, solve toolbar, pattern search) — v555

### ✅ Home Page Pixel-Perfect Review — COMPLETE (2026-03-05)
All 10 items addressed (most were already fixed by prior work):
- **Must-fix 1-2:** Duplicate puzzle card CSS consolidated; HR border fixed in both global reset + `.xw-hr--flush`
- **Should-fix 3-6:** Flexbox card layout with explicit thumb sizing; H1 on tokens (`.xw-home__heading`); mobile scroll-fade tabs; thumb overflow fixed
- **Suggestions 7-10:** Tab icons inline (`.tab-label` flexbox); Lora italic byline; card hover lift restored; min-height on sparse tab panels
- **Files:** `_components.scss`, `home.html.haml`
- **No migration.** CSS-only changes.

### Planner → Builder: Edit Page Frontend Review (2026-03-05)
Picked up by Builder at 2026-03-05 00:30

**Scope:** Playwright + code review. See planner memory for full findings (13 items).

**Must-fix (3):**

1. **`scroll_to_selected` JS crash after void toggle** — TypeError on every cell/clue click after any void is toggled. Root cause: `number_cells()` sets `data-cell` on cells, making `corresponding_clue()` use `data-cell-num` lookup path. Edit page clues have `data-index`, not `data-cell-num` → empty jQuery set → `.position()` returns undefined.
   - **Files:** `crossword_funcs.js` (scroll_to_selected guard), `cell_funcs.js` (corresponding_clue edit-mode check)
   - **Fix:** (a) Guard: `if ($sel_clue.length === 0) return;` in `scroll_to_selected`. (b) Make `corresponding_clue()` / `corresponding_across_clue()` / `corresponding_down_clue()` check `cw.editing` and always use the `data-index` path when editing.

2. **Tool panels (Notepad/Pattern Search) cover entire viewport** — `.slide-up-container` is `position: fixed; height: 90%`. Opens to `top: 95px`. Hostile to editing workflow — you can't see the puzzle while using tools.
   - **Files:** `edit.scss.erb` (`.slide-up-container` rules), `edit.html.haml` (panel HTML structure)
   - **Recommendation:** Redesign as integrated sidebar panels (desktop: 250px alongside puzzle) or partial bottom sheets (mobile: max 40vh). This is a design task — Planner should design the layout before Builder implements.

3. **Row height jump when letter is typed** — visible row height change when first letter appears in a row. Previously diagnosed in planner memory (2026-03-04). Verify if fix was applied; if not, apply the absolute-positioning fix.
   - **Files:** `crossword.scss.erb` (`.letter` rules)

**Should-fix (5):**

4. Dead "Edit Settings" modal — remove gear button + modal, or repurpose.
5. Phone tool panel buttons overlap content when closed.
6. Phone switch labels clipped.
7. `number_clues()` produces "NaN." for hidden clues.
8. Event handler leaks on Turbo navigation (`ready()` .on() without .off()).

**Dead code to clean up (3):**

- `spin_title()` in edit_funcs.js (references nonexistent Spinner library)
- `jquery-ui-1.10.4.draggable.min` include in edit.html.haml (never used)
- `#tools` CSS block in edit.scss.erb (no matching HTML)

### ✅ Account Settings Rebuild — COMPLETE (2026-03-05)
All 10 phases built and tested. Moved to Pending Deploy above.

### Remaining visual items (not addressed):
- Solve page toolbar icons cramped on mobile (minor)
- Admin panel table unstyled (low priority)

## Backlog

### Clue Suggestions from Phrase DB
Creator feature: suggest clues during puzzle editing based on 53K existing phrases. Query by
word content + text prefix. Infrastructure ready (Phrase model, Word model, pg_search).
Not yet planned in detail — next after timer/next-puzzle ships.
