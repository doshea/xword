# Builder Memory

## Implementation Notes

### CrosswordPublisher cleanup (2026-03-04)
- `CrosswordPublisher` service already existed (flat implementation). Refactored into 5 named
  private helpers matching the `NytPuzzleImporter` pattern: `validate_complete!`, `create_crossword`,
  `apply_letters`, `assign_clues`, `clean_up_cells`, `apply_circles`.
- Deleted `Crossword#publish!` (was dead code — zero callers).
- Updated CLAUDE.md technical debt section: removed 3 already-resolved items (Newyorkable,
  publish controller extraction, SolutionsController auth).
- All 762 specs pass (1 pre-existing flaky: `PagesController#live_search`).

## Bugs Found & Fixed

### Row height jump on first letter (2026-03-04)
- `.letter` was in document flow; `line-height: 145%` pushed `<td>` height on first keystroke
- Fix: absolutely position `.letter` + flexbox centering. Works at all breakpoints since
  `height: 100%` inherits the cell size regardless of font-size changes.

### Focus jumps to end of filled word (2026-03-04)
- `next_empty_cell_in_word()` recursed to `is_word_end()` when no empty cells → landed on last cell
- Fix: check `in_directional_finished_word()` first; if true, use `next_cell()` instead

### Cell check flash effect (2026-03-04)
- Golden flash cascade on check_cell/check_word/check_puzzle
- `--color-cell-flash: #f5d87a` token, `.cell-flash::before` pseudo-element at z-index 1100
- Adaptive stagger: 0ms (single), 30ms/cell (word), scaled to ~1.2s sweep (full puzzle)
- `prefers-reduced-motion` respected in both CSS (animation: none) and JS (skip stagger + flash)
- Reflow trick (`cell[0].offsetWidth`) restarts animation on re-check of same cells

### Blurry puzzle preview thumbnails (2026-03-04)
- Preview images are 75×75px pixel art (5px/cell). CSS `width: 100%` was upscaling to 140px+.
- Fix: fixed 75×75, `image-rendering: pixelated`, `--color-cell-border` (near-black) border,
  `--radius-sm` (4px), grid tightened to `minmax(100px, 1fr)`. Applied to search + profile.

### Notification System (2026-03-04)
- **All 4 phases built in one session** — 48 new specs, all passing (752 total, 1 pre-existing flaky).
- **Phase 1 (Backbone):** Migration with 4 indexes (inbox, notifiable, dedup, dedup-null-notifiable),
  Notification model, NotificationService (class-method pattern), NotificationsChannel, controller
  with mark_read/mark_all_read, inbox views, badge CSS, nav bell icon, ActionCable JS.
- **Phase 2 (Friend Requests):** FriendRequestsController (create/accept/reject), friend_status
  partial with turbo_frame for dynamic updates, profile page now shows Add Friend/Request Sent/
  Accept+Decline/Friends! states. Updated existing `@is_friend` boolean to `@friend_status` symbol.
  Updated user spec that expected "Not Friends" text to "Add Friend".
- **Phase 3 (Comments):** Hooks in CommentsController#add_comment and #reply. Notifies puzzle owner
  on new comment, comment author on reply. Self-notification suppressed.
- **Phase 4 (Puzzle Invites):** Friends API endpoint (GET /api/users/friends), PuzzleInvitesController,
  Stimulus invite_controller.js for team modal friend list + send invite.
- **Dead code deleted:** `cable.js`, `channels/chatrooms.js` (unused — team_funcs.js creates own consumer).
- **Key decisions:** NotificationService broadcasts via ApplicationController.render (works outside
  request context). Accept/Decline buttons use `data: { turbo: false }` for full redirect (simpler v1).
  FriendRequest has `id: false` → use `delete_all` not `destroy!`.

### Test suite performance optimization (2026-03-04)
- **Baseline:** 814 examples in 83.5s (4 pre-existing flaky failures)
- **Result:** 814 examples in 60.3s — **28% faster**
- **Changes made:**
  1. Added `test-prof` gem (~> 1.4) for `let_it_be` support
  2. Pinned crossword factory from `random_dimension` (4–30) to fixed 5×5. Reduces worst-case
     from 2,700 DB inserts to 76 per crossword. `:smaller` trait kept as no-op alias.
  3. Converted 17 spec files to `let_it_be` for crossword/user records:
     - Request specs: check_functions, comments, ajax_csrf, api, puzzle_invites, notifications, friend_requests
     - Controller specs: comments_controller, pages_controller
     - View specs: show, _crossword_tab, _comment, _reply, _win_modal_contents
     - Channel: teams_channel
     - Model: comment
     - Service: notification_service
  4. Configured `require 'test_prof/recipes/rspec/let_it_be'` in spec_helper.rb
- **Key constraint:** `let_it_be` only works with `:transaction` strategy (non-JS specs).
  Feature specs (`:deletion` strategy) remain on `let`/`let!`. Feature specs now account for
  ~35s of the 60s total — browser startup dominates, not DB setup.
- **Safety rule:** Only convert `let` to `let_it_be` when the record is read-only within all
  examples. Any spec that mutates the crossword/cells/clues stays on `let`.

### Fix 8 test failures (2026-03-04)
- **Result:** 814 examples, 0 failures — 3 consecutive green runs.
- **Fix 1 (CSS):** `edit.scss.erb` line 11: `#settings-button` nested inside `.side-button` compiled
  to descendant selector. Changed to `&#settings-button` for compound selector (same element).
  This was also a production bug — settings gear was never fixed-positioned.
- **Fix 2 (render_views):** `pages_controller_spec.rb`: controller spec stub returned `""` from
  `render_to_string`. Added `render_views` to the describe block.
- **Fix 3 (deadlock):** `spec_helper.rb`: non-JS test branch had no deadlock retry. Added matching
  retry wrapper (2 retries, 0.5s sleep, connection pool disconnect).
- **Fix 4 (Cuprite timing):** `login_spec.rb:55`: negative assertion `not_to have_link('Login')`
  ran before Turbo redirect completed. Added positive wait `have_text('Welcome back')` first.

### Fix flaky circle_count test (2026-03-04)
- **Test:** `crossword_spec.rb:460` — `#circles_from_array` "errors if some cells are missing"
- **Root cause:** `let(:circle_count){rand(subject.area).ceil}` — `rand(25)` can return 0
  (integer), `.ceil` is a no-op on integers. With 0 circles, `circle_inputs` is all zeros,
  so `circle_inputs.index(1)` returns nil → `NoMethodError: undefined method '+' for nil`.
- **Fix:** Changed to `rand(1..subject.area-1)` — guarantees at least 1 circle.
- **Surfaced by:** 5×5 factory pinning (smaller area = higher probability of rand returning 0).

### Design Polish Pass (2026-03-04)
- **Fix 1:** `_notifications.scss` line 17: `var(--font-heading)` → `var(--font-display)` (token didn't exist, fell back to sans-serif). Also fixed in `plan.md` line 321.
- **Fix 2:** `.xw-prose` in `_components.scss`: added `letter-spacing: var(--tracking-tight)` to h1/h2, h2 left accent bar (`border-left: 3px solid var(--color-accent-muted)` + `padding-left`), replaced hr line with centered dinkus ornament (`✦ ✦ ✦`), increased hr margin to `--space-8`.
- **Fix 3:** `edit.scss.erb` toggle switches: `$switch-on-color: #3a7d5c` → `var(--color-accent)`, `$switch-off-color: #c4bbb2` → `var(--color-border)`. Both vars only used in `background:` and `border-color:` (no Sass math), so `var()` is safe.
- **Fix 4:** `global.scss.erb` `.xw-thumbnail`: `box-shadow: 2px 2px 4px rgba(0,0,0,0.2)` → `var(--shadow-sm)` (warm-tinted shadow token).
- **Note:** `$switch-off-color` changed from `#c4bbb2` to `--color-border` (`#d4c9b8`) — slightly lighter off state. If user prefers darker, add dedicated token.

### Admin Test Tools Dropdown (2026-03-04)
- **Fake Win** admin-only endpoint: `POST /crosswords/:id/admin_fake_win`
- Controller: `@current_user&.is_admin` guard → `head :forbidden`. Sets `@correctness = true`,
  renders `_win_modal_contents` partial as JSON `{ correct: true, win_modal_html: "..." }`.
- HAML: Separate `.xw-dropdown` after Check dropdown, wrapped in `- if is_admin?`. Uses
  `xw-btn--ghost` style and `tool` (wrench) icon.
- JS: `solve_app.fake_win` clears previous modal content (`.not('.xw-modal__close').remove()`)
  for re-triggerability, then prepends new HTML and calls `showModal()`.
- Created `app/assets/images/icons/tool.svg` (Feather-style wrench icon).
- 4 new request specs: admin with solution, admin without solution, non-admin (403), anonymous (403).
- Route added to `find_object` before_action list.
- **Extended with 3 more tools (2026-03-04):**
  - **Reveal Puzzle**: `POST /crosswords/:id/admin_reveal_puzzle` returns `{ letters: "..." }`.
    JS fills cells via direct `.text()` (not `set_letter`) to avoid 225 team broadcasts.
    Single `check_all_finished()` call at end for clue crossing-off.
  - **Clear Puzzle**: Pure client-side. Empties letters, removes check flags, un-crosses-off clues.
  - **Flash Cascade**: Pure client-side. Builds synthetic `{ mismatches: { index: false, ... } }`
    and calls `apply_mismatches()` — all values `false` so no flag classes, just golden flash.
  - 3 new request specs for reveal_puzzle (admin, non-admin 403, anonymous 403).
- **Concurrent agent conflict:** Other agent (default scope removal) reverted my changes from
  shared files. Had to re-apply all 4 file edits. Watch for this pattern with concurrent agents.

### Remove Crossword default_scope (2026-03-04)
- **3 production bugs fixed:**
  1. "Random puzzle" always returned newest — `ORDER BY created_at DESC, RANDOM()` meant RANDOM() never consulted
  2. Search results ignored pg_search relevance — `ORDER BY created_at DESC, pg_search_rank DESC`
  3. Admin crosswords sort broken — `ORDER BY created_at DESC, created_at ASC` (DESC always won)
- **What changed:**
  - Deleted `default_scope -> { order(created_at: :desc) }` from `crossword.rb`
  - Added explicit `.order(created_at: :desc)` to 6 controller queries (home tabs, anonymous home, NYT, user-made, profile, batch)
  - Admin controller: `.order(:created_at)` → `.order(created_at: :asc)` (explicit direction)
  - Search/live_search: NO explicit order added — pg_search relevance ranking takes over naturally
  - Random: `.order("RANDOM()")` unchanged — works correctly now that there's no default scope to prepend
  - Model cleanups: `.reorder(:title)` → `.order(:title)` in phrase.rb, clue.rb, word.rb (no scope to override)
  - Spec cleanups: `Crossword.unscoped.last` → `Crossword.order(:created_at).last` in 3 spec files; `Crossword.last` → same in 1 spec file
  - CLAUDE.md updated: domain notes + removed tech debt item
- **Key rule going forward:** Any new Crossword query that needs ordering must add explicit `.order()`. No implicit ordering exists.

### Fix Clue UTF-8 Double-Encoding (2026-03-04)
- **Root cause:** `Clue#strip_tags` passed content to Loofah without encoding guard. ASCII-8BIT
  strings (from HTTParty) interpreted as Latin-1 → double-encoded UTF-8 (e.g. "Québéc" → "QuÃ©bÃ©c").
- **Fix 1:** Encoding guard in `strip_tags` before_save: force ASCII-8BIT → UTF-8, fallback
  to ISO-8859-1 transcode if invalid.
- **Fix 2:** Data migration (`fix_double_encoded_clues`): finds clues containing `Ã`, reverses
  with `encode('ISO-8859-1').force_encoding('UTF-8')`, rescues UndefinedConversionError.
- **Fix 3:** Belt-and-suspenders `ensure_utf8` on NytPuzzleFetcher response bodies at source.
- **4 new specs** in `clue_spec.rb`: UTF-8 preserved, ASCII-8BIT preserved, HTML stripped w/ Unicode, ISO-8859-1 transcoding.

### Reveal Hints — Cell + Word (2026-03-04)
- **Migration:** `add_hints_used_to_solutions` — integer column, default 0, null false.
- **Controller:** `CrosswordsController#reveal` — returns `{ letters: { index: letter } }` for
  requested indices only. Never exposes full answer key. Increments `solution.hints_used` atomically
  via `increment!`. Solution lookup follows `check_completion` pattern (owner + team partner).
- **UI:** 2 items added to Check dropdown after Completion divider: "Reveal Cell", "Reveal Word".
- **JS:** `reveal_cell()`, `reveal_word()`, `apply_reveal()` in solve_funcs.js. Uses `set_letter(letter, true)`
  for team broadcasting. Flash animation on revealed cells. `check_all_finished()` + `update_unsaved()` at end.
- **Win modal:** Shows "💡 N hints used" when hints_used > 0 (lightbulb icon). `.win-modal__hints` CSS class.
- **Specs:** 10 new (9 reveal + 1 hints_used default). Anonymous reveal works (no auth required).
  Team partner hint tracking works. Void/out-of-range indices handled. 842 total examples, 0 failures.

### Welcome Page Rebuild (2026-03-04)
- **6 files changed:** 2 rewritten, 2 new, 2 deleted.
- **Stimulus `chalkboard_controller.js`** replaces jQuery `welcome.js.erb`. CSS `translateX(-50%)`
  transition on `.xw-chalkboard__slider` replaces `$('.slider').animate({'marginLeft': ...})`.
- **Full BEM structure** (`.xw-chalkboard__*`), all design tokens, no hardcoded colors.
- **Accessibility:** sr-only labels on all inputs, ARIA regions, autocomplete attributes, skip-to-content.
- **Mobile:** No chalkboard image below 640px → dark `--color-nav-bg` container, show/hide panels
  instead of sliding. `prefers-reduced-motion` disables transition.
- **"Just browsing?" bypass** below chalkboard → root_path.
- **Content moved** from `_chalkboard.html.haml` (layout partial) to `welcome.html.haml` (view).
  Fixes antipattern of layout depending on controller's `@user`.
- **Google Fonts preconnect** added to `logged_out_home.html.haml` (was missing → system fallback fonts).
- **Housekeeping:** Deleted empty `layouts.scss.erb` + removed from manifest. Folded `_dimensions.scss`
  (`$row-width: 62.5em`) into `_design_tokens.scss`. Removed `@import 'dimensions'` from `crossword.scss.erb`.
- **Skipped H3** (delete `.puzzle-tabs .xw-tabs__nav`): Plan said dead CSS but class is used in 4 views.

## Workflow Rules
- **Always commit before declaring done.** Implement → test → commit → update memory.
  Deployer can't deploy uncommitted work. Don't leave it for them to discover.

## Patterns
- Service objects follow class-method pattern: `ServiceName.action(args)` with
  `private_class_method` for helpers. Transaction wraps the pipeline. See `NytPuzzleImporter`,
  `CrosswordPublisher`, and `NotificationService`.
