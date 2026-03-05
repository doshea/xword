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

### 2026-03-04: Comprehensive Site Design Review (code-based, superseded by screenshot review)

**Superseded.** See screenshot-based review below for authoritative findings.

### 2026-03-04: Full Screenshot-Based Design Review

**Scope:** Playwright walkthrough of all 22 pages (logged-out + logged-in). Screenshots saved as `/screenshots/01-*.png` through `22-*.png`.

**Overall grade: B.** Downgraded from B+ after visual verification. Primary pages (solve, profile, search, about) are well-polished. But several pages have bugs (invisible button text, broken unicode), empty states feel unfinished, and there's a visible quality gap between the best and worst pages.

**Must-fix (3):**
1. **Hamburger menu labels invisible** (SS 11, 13) — Browse/Create/Notifications show icons only. Text is in DOM but visually hidden. Likely `.xw-nav__label` CSS too aggressive on mobile.
2. **CTA button text invisible** (SS 05, 20, 21, 22) — "Browse Puzzles", "Back to puzzles" render as solid green blocks. Text color may be inherited wrong or link lacks `.xw-btn` class.
3. **Search placeholder `\u2026` literal** (SS 09) — Unicode escape not rendered. Template issue.

**Should-fix (6):**
4. Forgot Password Send button uses danger-red (SS 10) — should be accent green
5. Empty-state pages barren (SS 01, 02, 03, 07, 12) — content-to-wood ratio ~20/80
6. Contact page weakest on site (SS 07) — 2 lines, no editorial treatment
7. Account settings vertical tabs (SS 15) — inconsistent with horizontal tabs elsewhere
8. New Puzzle preview misaligned (SS 18) — tiny grid in huge empty container
9. Unauthorized/Account Required lack Error page's polish (SS 21, 22 vs 20)

**Suggestions (5):**
10. Page title banner needs more vertical padding
11. Footer detached on short-content pages — consider sticky footer
12. Profile stats numbers in italic display font look decorative
13. Solve page toolbar cramped on mobile
14. Admin table unstyled (low priority)

**What's working well:** Profile page, About page, Error page illustration, Solve page, Login page, nav bar, design token system.

**Key insight:** About page (with accent bars, `✦` dividers, editorial typography) is the gold standard. Contact, Unauthorized, and Account Required should match its treatment. The error page crossword illustration is delightful — more pages should have this level of personality.

**Builder handoff:** Written to shared.md. 3 must-fix items are likely quick CSS/template fixes. Should-fix items 5-6 and 8-9 are design work requiring more thought.

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

### 2026-03-04: Edit page void/empty swap — root cause analysis (SUPERSEDED — see entry below)

**Original symptom:** Integer `0` vs string `"0"` mismatch. Fix applied: `l.to_s == "0"`. However, the fix left the `strip.empty?` clause which creates a SECOND corruption bug — see next entry.

### 2026-03-04: Edit Page Save Bugs — deep dive investigation

**Trigger:** User reported "save icon is in a weird spot and it doesn't even work."

**Investigation method:** Code trace + Playwright live reproduction. Created 5×5 puzzle, typed A and B, clicked save button. Observed: URL changed to `...edit#`, page DOM entirely replaced by Turbo, 23 empty cells became black voids, clues collapsed from 10 to 3.

**Bug 1 — Empty cells corrupted to voids on every save (CRITICAL)**

Root cause: `update_letters` (`unpublished_crosswords_controller.rb:29`) maps `" "` → nil. JS `get_letter()` (`cell_funcs.js:233`) returns `" "` for unfilled cells. Controller's `l.to_s.strip.empty?` evaluates true → nil. But nil = void, `""` = non-void empty cell (per `populate_arrays` at `unpublished_crossword.rb:95`).

Affects BOTH manual saves AND auto-save (fires every 15s). Every save cycle corrupts more cells.

Fix: Change the mapping so `strip.empty?` produces `""` (not nil). Exact code in shared.md handoff.

**Bug 2 — Missing `e.preventDefault()` in save_puzzle (MUST-FIX)**

`save_puzzle(e)` at `edit_funcs.js:140` never calls `e.preventDefault()`. Save button is `<a href="#">`. Without it, Turbo Drive intercepts the `#` hash navigation, re-fetches the page, and replaces the entire DOM — destroying all client state.

Solve page's `save_solution` at `solve_funcs.js:118` correctly has `if (e) e.preventDefault();`. Same pattern needed. The `if (e)` guard matters: auto-save calls `save_puzzle()` with no event argument (line 17).

**Layout issue:** Save button left-aligns on narrow screens due to flex-wrap. Fix: `margin-left: auto` on `#puzzle-controls`.

**Handoff:** Written to shared.md as "Edit Page Save Bugs — CRITICAL" section with exact code fixes, test spec, and data repair guidance.

### 2026-03-04: Playwright MCP Server — headless screenshot capability

**Problem:** No way to visually verify design work. All CSS/HAML reasoning is code-only.

**Solution:** Official `@playwright/mcp` server (Microsoft) added as MCP tool. Headless Chromium — no visible windows, no focus stealing, no interference with user's work.

**Setup:** `claude mcp add --transport stdio playwright -- npx -y @playwright/mcp@latest --headless`

**Key tools gained:** `browser_navigate`, `browser_take_screenshot`, `browser_click`, `browser_type`, `browser_fill_form`, `browser_resize`, `browser_snapshot` (accessibility tree), `browser_console_messages`.

**Design workflow change:** Screenshot current state → analyze → propose → Builder implements → screenshot again → verify. Eliminates blind CSS reasoning.

**Auth approach:** Persistent browser profile (cookies survive sessions). Log in once, browse auth'd pages freely.

**Gotchas:**
- `--headless` flag is REQUIRED (default is headed/visible)
- `-y` on npx prevents hang on first-run install prompt
- First run downloads Chromium (~150MB) — pre-install with `npx playwright install chromium`
- Dev server must be running for localhost screenshots

### 2026-03-04: Pixel-Perfect Home Page Review

**Method:** Playwright screenshots at 3 breakpoints (desktop 1280×900, tablet 768×1024, mobile 375×812). Evaluated JS to measure computed styles, bounding rects, spacing. 15 test crosswords across 3 solution states.

**Screenshots:** `screenshots/hp-01-desktop-new-puzzles.png` through `hp-05-tablet-new-puzzles.png`

**Overall grade: B+.** The page works well across breakpoints and the "paper on wood" aesthetic is effective. However, the puzzle card component has structural CSS debt (duplicate rules, wrong internal grid) and several spacing values use browser defaults instead of design tokens.

**Critical CSS finding — duplicate `.xw-puzzle-card` definitions:**

Two competing rule blocks in `_components.scss`:

| Property | Lines 219-264 (nested, wins) | Lines 861-919 (standalone, dead) |
|----------|------|------|
| Title font | `--font-display` (Playfair Display) | `--font-body` (Lora) |
| Title size | `--text-base` (16px) | `--text-sm` (13px) |
| Title weight | `--weight-bold` (700) | `--weight-semibold` (600) |
| Byline font | `--font-ui` (DM Sans) | `--font-body` (Lora) italic |
| Byline color | `--color-text-muted` | `--color-text-secondary` |
| Card radius | `--radius-lg` (12px) via @extend | `--radius-md` (8px) override wins |
| Hover shadow | `--shadow-md` + translateY (from .xw-card) | `--shadow-sm` only (weaker, overrides .xw-card hover) |

**Recommendation:** Delete lines 861-919. Merge desired properties into lines 219-264. Specifically:
- Title: use Lora `--font-body` at `--text-sm` (13px) with `--weight-semibold` — better small-size readability
- Byline: use Lora `--font-body` italic — editorial warmth, differentiates from dims
- Keep `.xw-card` hover behavior (lift + medium shadow) by not overriding it
- Keep `--radius-lg` from `.xw-card` (the `--radius-md` override at line 863 is a mistake)

**Structural issue — 12-column grid inside cards:**
- `.xw-grid` inside `.xw-puzzle-card` creates 12 columns at 5.4px each in a 243px card
- 75px thumbnail in a 69.7px grid cell → overflow (clipped by card's `overflow: hidden`)
- Replace with flexbox: `.xw-puzzle-card__inner { display: flex; align-items: center; padding: var(--space-2); }`
- Thumb: `width: 75px; flex-shrink: 0;`
- Meta: `flex: 1; min-width: 0;`

**Spacing audit:**
- H1 margin: 21.44px (browser default, not on token scale) → should be `var(--space-5)` or `var(--space-6)`
- HR border: `1px inset` (3D groove) → should be `border: none; border-top: 1px solid var(--color-border)`
- Container top: 24px (from search.scss.erb) + 21.44px (h1 margin) = 45.4px → top-heavy

**Mobile finding:**
- "Solved Puzzles (2)" tab truncated at 375px — no scroll affordance
- Cards stack cleanly with centered thumbnails — good

**Handoff:** Written to shared.md with severity ratings and fix recommendations.

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

### 2026-03-04: Persistent Black Tabs + Hint Word — v2 reveal design

**Enhancement:** Revealed cells need visual distinction from checked cells and must persist across reloads.

**Key design decisions:**
1. **Black tab** via `.revealed .flag` CSS rule using `--color-text` — visually distinct from green (correct) and red (incorrect). Rule placed after `.correct`/`.incorrect` for source-order precedence.
2. **`revealed_indices` text column on solutions** — JSON array of cell indices. Merged (deduped) on each reveal. Parsed into a `Set` in controller `show` for O(1) lookup. Rendered server-side as `flagged revealed` classes on `<td>`.
3. **Reveal Cell → Reveal Letter** — rename only, same behavior.
4. **Reveal Word → Hint Word** — new behavior: picks one random empty (unfilled) cell from the current word. Prefers empty cells; falls back to non-revealed cells with letters. Client-side randomization; sends single index to existing `/reveal` endpoint.
5. **Check guard** — `apply_mismatches()` skips cells with `.revealed` class so checking never overwrites the black tab.
6. **Team limitation** — teammates see the letter in real-time (via ActionCable broadcast) but don't see the black tab until reload. Same pattern as check flags — not worth a separate broadcast.

**Files:** 7 modified + 1 new migration. 854 examples, 0 failures.

### 2026-03-04: Homepage "Load More" Pagination — design

**Problem:** Homepage shows "100 of 300 puzzles" with no way to see more. Dead `batch` endpoint was an earlier broken attempt (URI too long from passing all IDs in query string).

**Approach:** Turbo Stream load-more button. `POST /home/load_more` with `scope` + `page` params. Server returns Turbo Streams: `append` cards to `<ul>`, `replace`/`remove` button.

**Key decisions:**
1. Offset pagination (not cursor) — ordering is stable (`created_at desc`), no concurrent inserts during browsing.
2. All 3 tabs get unique `list_id` attributes (`unstarted-list`, `in-progress-list`, `solved-list`) as Turbo Stream targets.
3. Anonymous users get same UX but only `unstarted` scope (other scopes need a user).
4. Dead code deleted: `batch` route + controller + view + broken button partial.

**Bug found:** `_in_progress.html.haml` empty-state links `#panel2` (itself) instead of `#panel1` (New Puzzles). Fixed in plan.

**Full plan:** `claude_personas/memory/plan.md`

### 2026-03-04: NYT Page Day-of-Week Tabs + Calendar View — plan review

**Plan source:** User provided a multi-file implementation plan. I reviewed against codebase.

**Key findings from codebase review:**
1. `Crossword.created_at` is set to actual NYT publication date (NytPuzzleImporter line 62), NOT import date. Day-of-week grouping is correct.
2. Existing tabs Stimulus controller hardcodes `xw-tab--active` / `xw-tab-panel--active` class names — can't reuse for view toggle. Separate nyt-view controller is correct approach.
3. Nested Stimulus controllers (nyt-view wrapping tabs) — different identifiers, no target scoping conflict. Verified.
4. `.puzzle-tabs ul` CSS Grid rule provides card layout. `columns_class: 'puzzle-tabs'` must be preserved in topper_stopper call.
5. Mobile tabs: `.xw-tabs__nav` already has `overflow-x: auto` with hidden scrollbar. 7 tabs will scroll on narrow screens. Works.
6. No existing controllers use Stimulus `values` API — only `targets`. Sprockets-bundled Stimulus may not support it. Builder must test; dataset fallback provided.

**Issues found and fixed in plan:**
- (must-fix) Nil ivars on early return — view would crash if `@nytimes_user` nil
- (must-fix) Double DB query — `.size` then `.group_by` = 2 roundtrips. Fixed with `.to_a` first
- (should-fix) View panel visibility CSS missing from original plan — `.nyt-view-panel { display: none }` added
- (should-fix) Stimulus values API uncertain — fallback pattern provided

**Full plan (revised):** `claude_personas/memory/plan.md`

### 2026-03-04: NYT Calendar audit — smart init + year navigation

**Trigger:** User reported calendar opens on month/year with no puzzles. "We probably shouldn't
be starting users on a year/month where there are no puzzles from NYT."

**Audit findings:**
1. `calendar_controller.js` uses Stimulus values API (`static get values()`). Bundled Stimulus
   3.x DOES support values. However, no dataset fallback exists. If values return empty strings,
   calendar falls back to `new Date()` (March 2026) with empty puzzle data — completely broken UX.
2. `invite_controller.js` also uses values API but is NOT yet deployed to production — so there's
   no production validation that the values API pattern works with this Sprockets build.
3. Navigation is month-by-month only. Puzzles span ~60 months (2013–2017). Tedious.
4. No orientation cues (no puzzle count, no year-level nav).

**Design decisions:**
- Dataset fallback: read `this.element.dataset.calendarPuzzlesValue` etc. as safety net. Zero
  cost if values API works. Eliminates the blank-calendar failure mode.
- Year buttons (not dropdown): matches existing design patterns (day tabs, view toggle buttons).
  5 buttons for 5 years — clean, no overflow on any screen.
- Smart prev/next (skip empty months): builds month index at connect time from puzzle keys.
  O(n) once, O(1) per nav. 60-iteration safety cap prevents infinite loop.
- Puzzle count in header: simple text append, no new server data needed.
- Smart init: validate starting month has puzzles; walk backward if not.

**No server-side changes needed.** All fixes in `calendar_controller.js` + `_components.scss`.
Specs added for server-rendered data attributes (min/max/paths).

**Full plan:** `claude_personas/memory/plan.md`

### 2026-03-04: Solve Timer + Next Puzzle on Win — builder-ready plan

**Scope:** Two additive features. 6 files, 0 migrations, 0 new files.

**Timer design:**
- `solution.created_at` passed to JS as epoch ms via inline script
- Client-side `setInterval(1s)` with `render_timer()` function
- Freezes on win (clearInterval in check_completion success callback)
- Already-complete puzzles show frozen final time from `solved_at - created_at`
- Anonymous users: no timer (no solution). Turbo nav: clearInterval in `ready()`
- Format: `MM:SS` → `H:MM:SS` → `Dd H:MM:SS`. Monospace, muted.

**Next puzzle design:**
- `Crossword.new_to_user(@current_user).order("RANDOM()").first` in check_completion
- Anonymous fallback: `Crossword.where.not(id: @crossword.id).order("RANDOM()").first`
- Rendered as link + title in win modal bottom (`.win-modal__next`)
- Same logic added to `admin_fake_win` for consistency

**CLAUDE.md staleness identified:** All 6 runtime risks are fixed. All 4 architecture
principles are complete. CellEdit model deleted. Test count ~893 not ~693. Handoff to
Builder to update.

**Full plan:** `claude_personas/memory/plan.md`

### 2026-03-04: Backlog sprint — 3 items scoped and planned

**Items assessed:**

1. **Puzzle Card BEM Rename** — fully scoped. 7 files, 8 class renames. 1 CSS file, 1 partial,
   4 layout callers, 1 test file. Zero JS references. Mechanical rename, zero risk. ~45 min.

2. **Stats Page Modernization** — fully scoped. Chart.js v0/v1 (2013, vendored 38-line minified
   file) → Chart.js v4 via CDN. Key insight: stats is the ONLY Chart.js consumer in the entire
   app, so CDN is better than vendoring 200KB into every page. Inline `:javascript` HAML blocks
   → Stimulus `stats` controller. Canvas DPI blurriness fixed by Chart.js v4 `responsive: true`.
   3 files modified + 1 deleted. ~2 hours.

3. **Test Suite Performance** — assessed as **already complete**. `test-prof` installed (Gemfile
   line 70), `let_it_be` required in spec_helper, 19 files already converted. Remaining specs
   (crossword_spec 105 examples, solution_spec 21, solutions_spec 45) all mutate data and
   cannot use `let_it_be`. Estimated remaining gain: 1-3% (~1-2 seconds). Closed.

**Full plan:** `claude_personas/memory/plan.md`

### 2026-03-05: Edit Page Full Frontend Review (Playwright + code)

**Scope:** Live browser testing at 1440px (desktop), 768px (tablet), 375px (phone). Tested cell selection, typing, void toggle, clue editing, Notepad/Pattern Search panels, settings modal, toggle switches. Code review of edit.scss.erb, crossword.scss.erb, edit_funcs.js, crossword_funcs.js, cell_funcs.js, edit HAML templates.

**Overall grade: C+.** Core editing works on desktop but there's a production JS crash, broken tool panels, and poor mobile experience.

**Must-fix (3):**

1. **`scroll_to_selected` JS crash after void toggle** — `number_cells()` sets `data-cell` on cells → `corresponding_clue()` uses `data-cell-num` lookup → edit page clues only have `data-index` → empty jQuery set → `.position()` returns undefined → TypeError on every subsequent cell/clue click. Fix: guard in `scroll_to_selected` (`if ($sel_clue.length === 0) return;`) AND make `corresponding_clue()` use `data-index` path when `cw.editing`.

2. **Tool panels cover content on all viewports** — `.slide-up-container` is `position: fixed; height: 90%`. Opens to `top: 95px`, covering the entire puzzle grid with a dark overlay. Desktop Notepad covers left half; Pattern Search covers right half. Phone: even worse. Panels should be redesigned as side drawers (desktop) or partial bottom sheets (mobile).

3. **Row height jump on letter typed** — row visibly grows when first letter appears. Previously diagnosed. May still be present.

**Should-fix (5):**

4. Dead "Edit Settings" modal — gear button opens "Settings coming soon." placeholder. Either remove or repurpose (move toggle switches into it).
5. Phone: tool panel buttons overlap content permanently (fixed bottom positioning when closed).
6. Phone: "Mirror voids" switch label clipped at section boundary.
7. `number_clues()` produces "NaN." for non-word-start clues (hidden but sloppy DOM).
8. Event handler leaks on Turbo navigation — `.on()` in `ready()` without `.off()` causes duplicate handlers.

**Suggestions (5):**

9. `spin_title()` dead code (references nonexistent Spinner library). Delete.
10. Table lacks ARIA grid semantics.
11. Switch checkbox `display: none` — invisible to assistive tech. Use `sr-only` pattern.
12. `jquery-ui-1.10.4.draggable.min` loaded but never used. Dead dependency.
13. Inline `:css` block for clue height is fragile.

**What's working well:** Cell selection/word highlighting, void toggle with mirror, clue textareas with `field-sizing: content`, title/description AJAX saves with status feedback, auto-save deduplication counter, Publish confirmation, section `aria-label` attributes.

### 2026-03-04: Loading Feedback System — comprehensive audit + plan

**Trigger:** User reported puzzle card clicks and button presses feel unresponsive, especially
on production with Heroku latency. Barely-visible Turbo progress bar is insufficient.

**Audit scope:** All 96 HAML views, 14 Stimulus controllers, all jQuery AJAX in solve_funcs.js,
edit_funcs.js, global.js, new.js, solution_choice.js. Cataloged every server interaction and
its current feedback state.

**Key findings:**
1. `.xw-spinner` CSS class exists (global.scss.erb:157) but is **never used** anywhere
2. `loading_controller.js` Stimulus controller exists but is only wired to 3 of ~20 forms
3. `data-disable-with` used inconsistently — 11 places have it, 16 don't
4. Solve page AJAX buttons (check, reveal, hint, save) have **zero** loading feedback
5. Puzzle card clicks (the most common interaction) have only the progress bar
6. `turbo:click` event is available for intercepting navigation clicks globally

**Design decisions:**
- 4 implementation layers, ordered by impact-to-effort ratio
- Layer 1 (global nav dimming via `turbo:click`) covers ~80% of cases with ~1 hour of work
- Layer 2 (form `disable_with`) is mechanical application of existing pattern to 16 buttons
- Layer 3 (solve toolbar `.xw-btn--busy`) is highest UX value but most code
- Explicitly excluded: auto-save, live search, favorites, delete confirmations, client-side actions
- Used best practices per interaction type: nav → dim+spinner, form → disable+text, toolbar → busy state, destructive → confirm is enough, toggle → optimistic UI
- `prefers-reduced-motion` respected throughout

**Full plan:** `claude_personas/memory/plan.md`

### 2026-03-05: Account Settings Rebuild — planned + built

**Scope:** Replace 4-tab account settings (2 placeholder "Coming soon!" tabs) with single
scrollable page. 3 sections: Profile, Notifications, Account.

**Key design decisions:**
1. **Single page, no tabs** — kills the Puzzles/Emails placeholders, consolidates into 3 real sections
2. **Anonymize, don't delete** — user record stays with PII stripped, all FKs remain valid.
   `update_columns` bypasses validations to set placeholder email/username. Solutions, crosswords,
   and comments all survive intact for community.
3. **JSONB notification preferences** — opt-out model: empty hash = all enabled, `false` = muted.
   Setter coerces form checkbox strings to booleans. `NotificationService.notify` checks before creating.
4. **Email/username now editable** — added to `update_user_params`, uniqueness errors shown via
   `full_messages.to_sentence` (replaced generic error message).

**What was built:**
- Migration: `notification_preferences` (JSONB) + `deleted_at` (datetime) on users
- User model: `anonymize!`, `deleted?`, `notification_muted?`, `notification_preferences=` setter,
  `display_name`/`display_first_name` overrides for deleted state
- NotificationService: 1-line preference check
- UsersController: `delete_account` action, expanded `update_user_params`, profile guard for deleted users
- SessionsController: deleted user login block (defense in depth)
- Routes: `delete :delete_account`
- View rebuild: 3-section scrollable page (profile+photo, notification checkboxes, password+delete)
- CSS: removed tab styles, added checkbox styling + danger zone section
- ~8 view files updated for deleted user display (no linking to deleted profiles, `[Deleted Account]` text)
- 22 new tests across model, service, and request specs — all passing (207 related examples, 0 failures)

**Full plan:** `~/.claude/plans/silly-percolating-squirrel.md`
