# Planner Memory

## Architecture Decisions

### 2026-03-03: Publish extraction prioritized over default scope removal
- **Rationale:** Publish extraction is contained (1 controller action → 1 service), well-tested (7 request specs), and follows established pattern (NytPuzzleImporter). Default scope removal has 34 call sites and higher blast radius — worth a dedicated session.
- **Dead code bundled in:** `Crossword#publish!` (unused model method). Originally thought `Publishable` was dead too — **corrected below**.
- **Team broadcast extraction skipped:** The private `team_broadcast` method in SolutionsController is already clean — 6 lines with Redis error handling. Not worth extracting to a service.
- **`published` column decision deferred:** No feature driving it. Deleting `publish!` cleans up the worst of the half-dead state.

### 2026-03-03: CrosswordPublisher interface designed
- Class-method-based service (`CrosswordPublisher.publish(ucw)`) following `NytPuzzleImporter` pattern
- Custom `BlankCellsError` for validation failures — controller maps exceptions to redirects
- 5 private class methods for 5 pipeline steps: create, letters, clues, cleanup, circles
- Full design on shared board for Builder handoff

## Review History

### 2026-03-03: Code review of publish flow + dead code audit
**Files reviewed:**
- `app/controllers/unpublished_crosswords_controller.rb` — publish action (lines 39–93)
- `app/models/crossword.rb` — `publish!` method (lines 372–382), default scope (line 26)
- `app/models/concerns/publishable.rb` — 15 scopes
- `app/controllers/solutions_controller.rb` — team_broadcast already clean
- `spec/requests/unpublished_crosswords_spec.rb` — 7 integration tests for publish
- `app/controllers/pages_controller.rb` — home action uses Publishable scopes

**Findings:**
- `Crossword#publish!` is never called anywhere. Safe to delete.
- ~~`Publishable` concern: 13 scopes defined, 0 used. Safe to delete.~~ **CORRECTED:** `PagesController#home` (lines 13–18) actively uses `new_to_user`, `all_in_progress`, `all_solved`. Most other scopes are internal dependencies. Only `standard`, `nonstandard`, `solo`, `teamed` are truly unused. **Publishable must NOT be deleted.**
- `error_if_published` doesn't exist at all (CLAUDE.md reference is stale).
- Default scope: 34 active call sites, most safe (find_by, any?, paginate with explicit order) but a few `.first`/`.last` calls could silently return wrong results.

### 2026-03-04: Two solve-mode bug fixes designed

**Bug 1 — Row height jump on first letter typed:**
- Root cause: `.letter` div is the only cell child in normal document flow. Its `line-height: 145%` creates a line box when text is inserted, and table layout overrides explicit `<td>` heights.
- Fix: Absolutely position `.letter` (matching `.cell-num`, `.flag`, `.circle` pattern). Use `line-height: 1.5em` for vertical centering.
- Risk: Low. All other cell children are already absolutely positioned. Visual verification needed across breakpoints.

**Bug 2 — Focus jumps to word end in fully-filled word:**
- Root cause: `next_empty_cell_in_word()` walks to `is_word_end()` when no empty cells remain.
- Fix: Use existing `in_directional_finished_word()` to detect complete words, then `next_cell()` instead of `next_empty_cell_in_word()`.
- Risk: Very low. Only changes behavior when word is fully filled — initial solve flow untouched.
- Key insight: `in_directional_finished_word()` (cell_funcs.js:318) already exists and is direction-aware. No new helper needed.

### 2026-03-04: Notification System plan v2 — detailed implementation plan

**Plan source:** User provided 4-phase plan. I reviewed against codebase and produced full implementation-ready plan.

**Key findings from codebase review:**
1. FriendRequest/Friendship tables confirmed `id: false` — `(sender_id, recipient_id)` lookups. No polymorphic `notifiable` for friend notifications.
2. `actioncable.js` is a gem asset — `javascript_include_tag 'actioncable'` works.
3. `cable.js` + `channels/chatrooms.js` confirmed dead code. Safe to delete.
4. `notifications` migration must use `t.integer` (not `t.references`) — `users.id` is integer, not bigint.
5. `ApplicationController.render` needed for ActionCable partial rendering.
6. Badge CSS: `.xw-badge` absolute inside `.xw-nav__item#nav-mail` (already `position: relative`).
7. Stimulus pattern: `class extends Stimulus.Controller`, `.targets`, `window.StimulusApp.register(...)`.
8. API users namespace already exists — `friends` endpoint adds naturally.
9. FriendRequest model spec uses `should` syntax — new specs use `expect()` only.
10. CommentsController `add_comment` guard-clause needs restructuring to if/else for notification.
11. Nav uses `is_logged_in?` helper, not `@current_user` directly.
12. Notification partial references Phase 2 route helpers — add routes early.

**Design decisions:**
- mark_all_read: simple redirect for v1 (no Turbo Stream per-row replacement)
- ActionCable: conditional load in layout, own consumer in notifications_channel.js
- Icon: `bell` instead of `mail`, but `#nav-mail` ID preserved for CSS compatibility
- Add Phase 2 routes in Phase 1 to avoid NoMethodError in notification partial

**Full plan:** `claude_personas/memory/plan.md` — ~600 lines with code snippets for every file.

### 2026-03-04: Cell check flash effect designed

**Feature:** Golden flash cascade on cell check (check cell / word / puzzle). Flash sweeps L→R, T→B then fades to reveal error flags.

**Approach:**
- CSS `::before` pseudo-element on `.cell-flash` class — z-index 1100 (above flag at 1000, letter at 1001)
- `@keyframes cell-check-flash`: opacity 0.6 → 0 over `--duration-slow` (300ms)
- JS stagger: adaptive per-cell delay (30ms for words, ~5ms for full puzzle, 0 for single cell)
- Reflow trick (`cell[0].offsetWidth`) to restart animation on re-check
- `prefers-reduced-motion` respected in both CSS and JS (follows existing patterns)

**Key decisions:**
- New `--color-cell-flash` token (#f5d87a) — same value as `--color-cell-selected` but separate token for independent tuning
- Error classes applied simultaneously with flash (not delayed) — flash overlay at 60% opacity covers the flag, fades to reveal it
- Empty cells in full-puzzle check DO get the flash (continuous wave) but no flag classes
- Legacy `check_cell.js.erb` NOT updated — rarely hit, low priority

**Risk:** Low. Pure additive CSS + JS changes. No DOM, controller, or model changes. No test impact.

**Files:** `_design_tokens.scss` (1 token), `crossword.scss.erb` (flash rules + reduced-motion), `solve_funcs.js` (replace `apply_mismatches`)

## Open Questions

- Default scope removal plan needed (future session). Key risk: queries that use `.first`/`.last` without explicit order.
- 4 unused Publishable scopes (`standard`, `nonstandard`, `solo`, `teamed`) — prune when convenient, not urgent.
- FriendRequest model spec (line 6-8) uses `should` syntax — should be migrated to `expect()` when touching that file.
