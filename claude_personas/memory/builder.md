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

## Patterns
- Service objects follow class-method pattern: `ServiceName.action(args)` with
  `private_class_method` for helpers. Transaction wraps the pipeline. See `NytPuzzleImporter`,
  `CrosswordPublisher`, and `NotificationService`.
