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

### 2026-03-04: Notification System plan v3 — builder-ready with all corrections applied

**Replaced plan.md** with complete builder-ready implementation plan. All 4 must-fix issues from v2 review are now embedded directly in the code snippets (not listed separately). Every file has exact code. Builder should follow plan.md as single source of truth.

**Key architectural validations confirmed against current codebase:**
- `friend_requests` table: `id: false`, columns: sender_id, recipient_id, accompany_message, timestamps. Indexes on sender_id and recipient_id individually.
- `friendships` table: `id: false`, columns: user_id, friend_id. Both indexed.
- `User#friends` returns AR::Relation via `.or()` query — suitable for API serialization.
- `User#friends_with?` uses `.exists?` — efficient for profile page status check.
- `ApplicationCable::Connection` returns nil for anonymous (no reject). `TeamsChannel` rejects based on params. `NotificationsChannel` will reject nil current_user.
- `team_funcs.js.erb` creates its own consumer (line 291) — completely independent of `cable.js`. Confirmed dead code.
- `ApiController` routes use `namespace :api, defaults: {format: :json}` with nested `namespace :users`. Friends endpoint adds as sibling `get :friends`.
- `application.scss` uses only Sprockets `*= require` directives (not SCSS `@import`). New `_notifications.scss` must follow this pattern.
- Existing Stimulus pattern: IIFE → `class extends Stimulus.Controller` → `window.StimulusApp.register()`. invite_controller.js follows this.
- `topper_stopper` layout partial used by 20+ pages including `users/show.html.haml`. Notifications inbox will use it with `columns_class: 'xw-md-center-8'`.

**Design decisions finalized:**
- Accept/Decline from inbox: `data: { turbo: false }` → full redirect (simple, reliable for v1)
- Avatar in notification partial: `actor.image.present?` guard with fallback to `default_images/user.jpg`
- `mark_all_read`: re-renders full notification list via Turbo Stream replace
- Phase 2 routes added in Phase 1 to prevent NoMethodError in notification partial
- Puzzle invite sends `head :ok` (no Turbo Stream) — button state managed in Stimulus JS
- `NotificationService.broadcast` wrapped in rescue to prevent broadcast failures from blocking notification creation

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

### 2026-03-04: Blurry puzzle preview thumbnails — root cause + fix

**Root cause:** `generate_preview` creates images at 5px/cell (75×75 for 15×15). CSS `width: 100%` in `minmax(140px, 1fr)` grid stretches them ~2x. Browser bilinear interpolation blurs the pixel-art grid lines.

**Fix:** Display at native 75×75 (matching home page `.minipic img` which already does this correctly). Tighten grid to `minmax(100px, 1fr)`. Black border (`--color-cell-border`). `image-rendering: pixelated` as insurance. Minimal `border-radius`.

**Files:** `search.scss.erb` (grid + thumb), `profile.scss.erb` (grid + thumb). No view/backend changes.

**User preference:** Wants them small. Confirmed 75px.

### 2026-03-04: Test suite performance audit

**Problem:** 814 examples in ~127s. Crossword factory is the bottleneck — each `create(:crossword)` inserts 76–2,700 DB records via `after_create :populate_cells`. RSpec `let` re-creates these per example even when tests only read the record. Conservative estimate: ~150 redundant crossword creates per run = ~11,400 unnecessary DB writes.

**Root causes identified:**
1. No `let_it_be` — every `let(:crossword)` rebuilds the full cell/clue tree per example
2. Random dimensions on bare `create(:crossword)` — 4×4 to 30×30 makes timing unpredictable
3. No `test-prof` gem installed — no profiling or optimization tooling
4. CSRF spec does full crossword page render to extract tokens (minor)

**Recommendation:** Add `test-prof` gem, convert ~10 spec files to `let_it_be`, pin dimensions. Target: suite under 80s (45% improvement).

**Key risk:** `let_it_be` + DatabaseCleaner interaction. `let_it_be` uses `before(:all)` + savepoints; our spec_helper uses `DatabaseCleaner.cleaning` with transaction strategy. Need to verify compatibility in Phase 1 before bulk conversion. Feature specs (`:deletion` strategy) may not be compatible — may need to keep `let!` there.

### 2026-03-04: Notification dropdown design (DotA2-style)

**Request:** Convert notifications from full-page redirect to in-nav dropdown panel.

**Approach:** New Stimulus controller (`notification-dropdown`) with lazy-load on first open. Fetches `/notifications/dropdown` (new route → HTML partial, no layout). Reuses existing `_notification.html.haml` partial in both dropdown and full page.

**Key architecture decisions:**
- Lazy fetch (not preloaded) — don't add notification HTML to every page
- Separate Stimulus controller — too much behavior for generic dropdown (fetch, markAllRead, refresh)
- JSON response for mark_all_read from dropdown — avoids Turbo Stream targeting conflicts (different container IDs between dropdown and full page)
- ActionCable calls `controller.refresh()` via `getControllerForElementAndIdentifier` — risk: API may not exist in our Stimulus version. Fails silently.
- Light background on desktop (paper aesthetic), dark in mobile hamburger menu (matches other dropdowns)
- Full `/notifications` page preserved via "See all" link

**Files:** 2 new (dropdown partial, Stimulus controller), 7 modified (routes, controller, nav HAML, nav SCSS, channel JS, notification spec). No model/service changes.

**Full plan:** `claude_personas/memory/plan.md`

### 2026-03-04: Comprehensive Site Design Review

**Scope:** Full audit of all view templates, stylesheets, and design token usage.

**Overall grade: B+.** Primary pages (solve, edit, profile, nav, search) are well-polished. Secondary pages use tokens correctly but lack visual character.

**Findings by severity:**

**Must-fix (1):**
- `_notifications.scss` line 17: `var(--font-heading)` doesn't exist in tokens → `var(--font-display)`. Same bug propagated to plan.md notification dropdown design (line 321).

**Should-fix (3):**
1. Info pages (about/FAQ/contact) visually barren. `.xw-prose` styles are technically correct but flat. Designed h2 accent bars + editorial dinkus (`✦  ✦  ✦`) section breaks + tighter heading tracking.
2. Edit page switch colors hardcoded as SCSS variables when identical tokens exist.
3. `_crossword_tab.html.haml` uses legacy class names (`.result-crossword`, `.minipic`, `.metadata`, `.title`, `.byline`, `.dimensions`, `.nyt-watermark`). Should be `xw-puzzle-card` BEM — but this is a 2-hour refactor touching 20+ template references. **Deferred** to a dedicated session.

**Suggestions (3):**
1. `.xw-thumbnail` has cold black shadow (`rgba(0,0,0,0.1)`) — should use `var(--shadow-sm)`.
2. Error/unauthorized/account_required pages are functional but could have more personality (illustrations, warmer messaging). Low priority.
3. Stats page uses Chart.js v1 API with hardcoded rgba colors and inline JS. Roughest page on the site. Modernization would take 3-4 hours — very low priority.

**Design token adoption:** ~88% of visual properties use CSS custom properties. Remaining holdouts are mostly in legacy puzzle-tab styles and edit.scss switches.

**Key insight:** The "paper on wood" aesthetic works well for primary pages but the info pages feel like they're missing the editorial layer. Adding Playfair Display tracking, accent bars on headings, and typographic section breaks (instead of plain `<hr>`) would bring them into line with the overall feel without touching any HTML.

**Builder handoff:** Written to shared.md with 4 prioritized changes. All CSS-only, no DOM/test changes.

### 2026-03-04: Admin test tools dropdown on solve page

**Request:** Admin-only dropdown on solve page with "Fake Win" to trigger win pathway without completing the puzzle.

**Approach:** Reuse existing `.xw-dropdown` + Stimulus `dropdown` controller. Separate dropdown from Check (different intent). `xw-btn--ghost` style with `tool` (wrench) icon. Server-side action because win modal needs rendered HTML (time calc, comment form, flightboard JS).

**Key design decisions:**
- Separate `admin_fake_win` controller action (not a param on `check_completion`) — clean separation
- Admin guard: `return head :forbidden unless @current_user&.is_admin` — returns 403 for non-admin AND anonymous
- Re-triggerable: JS clears previous modal content before prepending new (removes children except close button)
- Solution lookup duplicated from `check_completion` (~6 lines) — extracting a shared method would be premature for 2 callers

**Files:** 4 modified (routes, controller, show.html.haml, solve_funcs.js), 0 new. 4 request specs added.

**Full plan (v1):** built by builder. See shared.md.

### 2026-03-04: Admin tools v2 — Reveal Puzzle, Clear Puzzle, Flash Cascade

**Extending existing Admin dropdown** (Fake Win already built) with 3 additional tools.

**Design decisions:**
- **Reveal Puzzle** — server endpoint returns `@crossword.letters`. JS fills cells via direct DOM `.text()` (NOT `set_letter()`) to avoid: (a) 225 individual team broadcasts, (b) 225 `check_finisheds()` calls. One `check_all_finished()` at end. `update_unsaved()` triggers auto-save → `check_completion` callback marks solution complete automatically.
- **Clear Puzzle** — pure client-side. Clears letter text, removes flag classes (`flagged`, `incorrect`, `correct`, `cell-flash`), removes `crossed-off` from clues. Note: `check_completion` callback only sets `is_complete = true`, never reverts — clearing doesn't undo completion. Fine for testing.
- **Flash Cascade** — pure client-side. Calls existing `apply_mismatches()` with synthetic data (all cells, all `v=false`). No flag changes (only flash animation). Minor side effect: any cells with `incorrect` class get flipped to `correct` — acceptable for admin tool.
- **Set Timer** — deferred. Higher risk (modifying timestamps), needs UI for duration input, lower ROI since Fake Win already shows timer.

**Security:** `admin_reveal_puzzle` returns the full answer key — most sensitive endpoint. Same admin guard as `admin_fake_win`. Non-admin/anonymous get 403.

**Files:** Same 4 as v1 (routes, controller, show.html.haml, solve_funcs.js) + spec. 1 new route, 1 new action, 3 dropdown items, 3 JS functions, 3 click bindings, 3 request specs.

**Full plan:** `claude_personas/memory/plan.md`

### 2026-03-04: Default Scope Removal — comprehensive audit + plan

**Audit:** ~40 Crossword query call sites examined. 14 safe (find_by, any?, reorder). 8 need explicit `.order(created_at: :desc)`. 4 have active bugs caused by default scope.

**3 production bugs discovered and confirmed via `rails runner` SQL output:**
1. Random puzzle (`/random`) — `ORDER BY created_at DESC, RANDOM()` → RANDOM() never consulted, always returns newest puzzle
2. Search — `ORDER BY created_at DESC, pg_search_rank DESC` → date trumps relevance
3. Admin crosswords — `ORDER BY created_at DESC, created_at ASC` → explicit ASC ignored

**Key Rails insight:** `default_scope` ordering is prepended. Subsequent `.order()` calls APPEND (not replace). Only `.reorder()` replaces. This is why `.order("RANDOM()")` doesn't work — it becomes `ORDER BY created_at DESC, RANDOM()` and RANDOM() is never reached.

**Design decisions:**
- Search/live_search deliberately get NO explicit ordering — pg_search provides relevance ranking that was being suppressed
- `.order("RANDOM()")` → `.reorder("RANDOM()")` instead of just relying on scope removal (defensive — communicates intent)
- Admin `.order(:created_at)` → `.order(created_at: :asc)` for clarity even though `:asc` is the default
- Test cleanup: `Crossword.unscoped.last` → `Crossword.order(:created_at).last` (remove workaround, use explicit intent)

**Full plan:** `claude_personas/memory/plan.md` (replaced admin tools plan; that plan was already built)

### 2026-03-04: Puzzle Card BEM Rename — audit + plan

**Audit:** 8 render sites, 10+ CSS selectors, 2 test assertions, 0 JS references. 1 dead CSS block found (`.puzzle-tabs .xw-tabs__nav` → no matching HTML).

**Class mapping:** `.result-crossword` → `.xw-puzzle-card`, `.minipic` → `__thumb`, `.metadata` → `__meta`, `.title` → `__title`, `.byline` → `__byline`, `.dimensions` → `__dims`, `.nyt-watermark` → `__nyt`, `.puzzle-tabs` → `.xw-puzzle-grid`.

**Low priority** — mechanical rename, no bugs, no visual change. ~2 hours.

### 2026-03-04: Solve Timer + Next Puzzle on Win — detailed design

**Feature gap analysis** identified 4 high-value missing features. User approved designing the top 2:

**Solve Timer findings from codebase review:**
1. `#puzzle-controls` already has `#save-status` + `#save-clock` — timer fits naturally alongside.
2. `solution.created_at` available server-side but NOT currently passed to JS (only `solution_id` + `crossword_id`). Need to add.
3. Win modal already calculates elapsed time via `time_difference_hash(updated_at, created_at)` — but only server-side on win. Timer during play is pure client-side.
4. `solution.solved_at` set by `before_save :check_completion` callback when `letters == crossword.letters`. Used to freeze timer on completed puzzles.
5. Existing interval cleanup pattern in `ready()` prevents stale timers on Turbo navigation.

**Next Puzzle findings:**
1. `Crossword.new_to_user(user)` scope exists — chains through `unowned`, `unstarted`, excludes partnered puzzles. Perfect for "what haven't you tried?"
2. Must use `.reorder("RANDOM()")` not `.order("RANDOM()")` — same default scope bug as `/random` (pre-removal).
3. Win modal content rendered server-side in `check_completion` as `render_to_string(partial:)`. Controller is the right place for the next puzzle query.
4. Current puzzle guaranteed excluded from `new_to_user` results because solution already exists when `check_completion` fires.
5. Anonymous users have no `@solution` in the win modal path — but the "Next Puzzle" link should still appear. Handled with fallback to `/random`.

**Remaining feature candidates** (not yet designed):
- Reveal Hints (letter/word) — reduces puzzle abandonment, needs `hints_used` column on Solution
- Clue Suggestions from Phrase DB — creator experience, 53K phrases exist, infrastructure ready

### 2026-03-04: Welcome Page Rebuild — comprehensive design review + plan

**Scope:** Full audit of all 21 stylesheets, 117 view templates, and design token coverage.

**Overall assessment: A−.** Primary pages polished. Token adoption ~88%. Three areas below the bar:

1. **Welcome page** (HIGH) — Biggest gap. ~15 hardcoded colors, no accessibility, dead Foundation attributes, jQuery animation, no responsive. Full rebuild planned.
2. **Stats page** (LOW) — Chart.js v1 (EOL), inline JS, hardcoded rgba. ~3 hours. Low traffic.
3. **Housekeeping** (TRIVIAL) — empty `layouts.scss.erb`, single-var `_dimensions.scss`, dead CSS block. Bundled with welcome rebuild.

**Key findings:**
- `welcome.html.haml` is 0 bytes. Content in `_chalkboard.html.haml` rendered by layout. Antipattern.
- `UsersController#create` fails → `/users/new`, not `/welcome`. Form errors never shown on chalkboard.
- `logged_out_home.html.haml` doesn't load Google Fonts — welcome page uses fallback fonts.
- `data-abide: true` dead (Foundation removed). Dev comment left in. No responsive CSS.
- Chalkboard 23.3em × 29.5em overflows on phones <375px.

**Decision:** Rebuild implementation, keep visual concept. Desktop: chalkboard image + CSS slide. Mobile: dark container, show/hide.

**Full plan:** `claude_personas/memory/plan.md`

### 2026-03-04: Sleeker Footer — Colophon Strip Redesign

**Request:** Replace chunky dark footer with transparent colophon strip.

**Review findings:**
- Plan is clean. 2 files, no JS, no tests, no model changes.
- All 10 design tokens referenced in the CSS exist in `_design_tokens.scss`.
- `$bp-sm` SCSS variable exists (640px) for mobile breakpoint.
- `icon()` helper confirmed (accepts `name` + `size:` kwarg) — same calls as current footer, just smaller size (14 vs 18).
- `--color-footer-bg` becomes unused but harmless — no cleanup needed.
- Both layouts (`application.html.haml`, `logged_out_home.html.haml`) render same `_footer` partial — no layout changes.
- No existing footer specs, so rspec is a regression check only.

**Risk:** Very low. Pure visual change. No behavior, no JS, no data.

## Open Questions

- ~~Default scope removal plan needed (future session)~~ **DONE** — plan written, fixes 3 bugs.
- 4 unused Publishable scopes (`standard`, `nonstandard`, `solo`, `teamed`) — prune when convenient, not urgent.
- FriendRequest model spec (line 6-8) uses `should` syntax — should be migrated to `expect()` when touching that file.
- `let_it_be` compatibility with DatabaseCleaner `:deletion` strategy (feature specs) — needs testing.
- Stimulus version check: does `StimulusApp.getControllerForElementAndIdentifier()` exist? If not, need fallback pattern for ActionCable → dropdown refresh.

### 2026-03-04: Test failure root cause analysis (8 failures → 4 fixes)

**Investigation method:** Full suite run (8 failures), then isolated runs to classify always-failing vs intermittent.

**Always-failing (4 tests):**
1. `edit_spec.rb:35, 41, 115` — CSS nesting bug. `.side-button { #settings-button { ... } }` compiles to descendant selector, but element has both class+id. `position: fixed` never applies. Settings button overlaps ideas button at viewport bottom. Also a **production visual bug** (settings gear was never fixed-positioned on right edge).
2. `pages_controller_spec.rb:28` — Missing `render_views` in controller spec. `render_to_string(partial:)` returns `""` without it. **Not flaky** — correcting earlier memory note.

**Intermittent (4 tests):**
3. `admin/clues_controller_spec.rb` (2 tests) — PG deadlock. JS test Puma thread + non-JS test both creating crosswords → bulk `INSERT INTO clues` deadlocks. Non-JS branch lacked retry.
4. `login_spec.rb:48` — Cuprite timing. Missing positive assertion before negative check after Turbo redirect.
5. `users_spec.rb:47` — Order-dependent, likely related to deadlock. No specific fix needed.

**Key correction:** The MEMORY.md note about "1 pre-existing flaky failure: PagesController#live_search" was wrong — it's a deterministic failure caused by missing `render_views`, not flakiness.

### 2026-03-04: Clue UTF-8 double-encoding — root cause + fix

**Symptom:** Clues with accented characters display as mojibake: "Québéc" → "QuÃ©bÃ©c"

**Root cause confirmed via reproduction:** `Clue#strip_tags` uses Loofah (via `ActionController::Base.helpers.strip_tags`). When the input string has `ASCII-8BIT` encoding (which HTTParty can produce), Loofah's Nokogiri HTML parser interprets the bytes as Latin-1 and re-encodes to UTF-8. The 2-byte UTF-8 sequence `c3 a9` (é) becomes 4 bytes `c3 83 c2 a9` (Ã©).

**Key finding:** `strip_tags` and `sanitize` both handle UTF-8 correctly when encoding is tagged properly. The bug is ONLY triggered when the Ruby string's encoding metadata is `ASCII-8BIT` instead of `UTF-8`. The security measures are correct and should stay.

**Fix:** 3 changes — encoding guard in Clue model (before strip_tags), data migration for existing corrupted clues, source-level encoding fix in NytPuzzleFetcher.

**No cell changes needed.** Cell letters are A-Z only by data model design, rendered with HAML auto-escaping.

**Handoff:** Written to shared.md with full code snippets for Builder.

### 2026-03-04: Reveal Hints (Letter + Word) — feature design

**Feature:** Solvers can reveal the correct letter for a single cell or an entire word when stuck. Tracked per solution.

**Key design decisions:**
1. **Single endpoint** `POST /crosswords/:id/reveal` — cell vs word is just different `indices` arrays. Follows `check_cell` pattern on CrosswordsController.
2. **Returns only requested letters** — never the full answer key. Security: can't get full grid from one request.
3. **`hints_used` integer on solutions** — atomic `increment!`, counts per cell revealed (5-letter word = 5 hints).
4. **UI in Check dropdown** — Reveal Cell + Reveal Word after a divider. Natural grouping: check → reveal.
5. **Team broadcasting** — `set_letter(letter, true)` handles it automatically.
6. **No Reveal Puzzle** for regular users — stays admin-only. Cell + word only for v1.
7. **Win modal shows hint count** if > 0 — subtle muted text, not judgmental.
8. **Anonymous users** can reveal (no auth required, same as check_cell) but no tracking.

**Files:** 7 modified + 1 new migration + 1 new spec file. Low risk — purely additive.

**Full plan:** `claude_personas/memory/plan.md`
