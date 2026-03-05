# Builder Memory

## Workflow Rules
- **Always commit before declaring done.** Implement → test → commit → update memory.
- **Run `bundle exec rspec` after non-trivial changes.** "Should work" ≠ "does work."
- **Picking up a plan:** Add `Picked up by Builder at YYYY-MM-DD HH:MM` to the item on
  `shared.md`. If it already has a pickup timestamp within the last 15 minutes, **stop** —
  another Builder is working on it. After 15 min with no commit, the pickup expires.

## Patterns & Conventions

### Code
- Service objects: class-method pattern with `private_class_method`. See `NytPuzzleImporter`, `CrosswordPublisher`, `NotificationService`.
- Crossword has **no default scope**. Every query needing order must add explicit `.order()`.
- `FriendRequest` has `id: false` → use `delete_all` not `destroy!`.
- NotificationService broadcasts via `ApplicationController.render` (works outside request context).

### Testing
- No `require 'rails_helper'` — specs use `spec_helper` via `.rspec` config.
- Turbo Stream endpoints need `headers: { 'Accept' => Mime[:turbo_stream].to_s }` in request specs (otherwise 406).
- `let_it_be` only for read-only records in `:transaction` strategy specs. Feature specs (`:deletion`) stay on `let`/`let!`.
- Crossword factory pinned to 5×5. `:smaller` trait is a no-op alias.

### CSS/JS
- **`.xw-prose a` specificity bug**: `.xw-prose a` (0,1,1) overrides `.xw-btn` (0,1,0) color. Fixed with `.xw-prose a:not(.xw-btn)`. Check for similar specificity traps when nesting link components inside prose containers.
- **HAML `!=` for HTML strings**: `_crossword_list.html.haml` uses `%p!= empty_message` because the message can contain `link_to` HTML. Regular `=` escapes it.
- **`.xw-nav__label`**: Hidden on desktop (`display: none`), shown on mobile (`display: inline` inside mobile media query). Use for icon buttons that need text in hamburger menu.
- **Sticky footer**: `body { display: flex; flex-direction: column; }` + `#body { flex: 1 0 auto; }`. Footer auto-sticks to bottom on short pages.
- **HAML unicode escapes**: `'\u2026'` (single quotes) is LITERAL. Must use `"\u2026"` (double quotes) for Ruby to interpret the escape.
- `.xw-puzzle-grid .xw-tabs__nav` CSS is NOT dead — class used in 4 views. (Renamed from `.puzzle-tabs` in BEM sprint.)
- jQuery `.position()` returns coords relative to nearest positioned ancestor — grep for `.position()` and `.offset()` when changing CSS `position` properties.
- **Edit page tool panels**: `.slide-up-container` uses `position: fixed; bottom: 0; top: 100%` (closed) / `top: 55%` (open). The `.bottom-button` at `top: -1.5em` peeks above viewport bottom as a clickable tab handle. Don't push `top` past `100%` or the buttons become invisible/unreachable.
- **Edit page `corresponding_clue()`**: Edit clues use `data-index`, solve clues use `data-cell-num`. After `number_cells()` sets `data-cell` on cells, the function would use the wrong lookup path. Fixed with `if (cw.editing) return` early-return using the `data-index` path.
- Admin tools: `@current_user&.is_admin` guard → `head :forbidden`. Wrapped in `- if is_admin?` in HAML.
- Reveal Puzzle JS uses direct `.text()` not `set_letter()` to avoid N team broadcasts.
- **Stats page**: Chart.js v4 vendored locally (`chart.umd.min.js`, loaded via `javascript_include_tag` in `content_for :head`), only on stats page. Stimulus `stats` controller renders charts. `pointRadius: 0` with `pointHitRadius: 8` for 1000+ data points.
- **Solve timer**: Client-side `setInterval(1s)` in `solve_funcs.js`. Uses `solve_app.started_at` (epoch ms from `solution.created_at`). Freezes on win or if `is_complete` is true on load. Format: `MM:SS` / `H:MM:SS` / `Dd H:MM:SS`.
- **Next puzzle on win**: `@next_puzzle` set in `check_completion` controller action. Uses subquery `Crossword.where(id: Crossword.new_to_user(...))` to avoid PG `DISTINCT + ORDER BY RANDOM()` conflict.
- **Loading feedback patterns**:
  - Global: `turbo:click` → `.xw-loading` on clicked element. Clean up on `turbo:before-render`/`turbo:load`.
  - Forms: `data: { disable_with: 'Text…' }` — Rails/Turbo convention. Works with `button_to`, `submit_tag`, `f.submit`.
  - AJAX toolbar: `.xw-btn--busy` class + `prop('disabled', true)` before `$.ajax`, restore in `complete` callback.
  - Save auto-save vs manual: Only show busy state when `e` (event) param is truthy (manual click), not when called by auto-save timer.
  - `_check_trigger()` helper returns the "Check ▾" dropdown trigger button — shared by 6 functions.
  - `solution_choice.js`: programmatic `Turbo.visit` doesn't fire `turbo:click`, so add `.xw-loading` manually.

## Known Flakes
- JS feature specs (login_spec, home_tabs_spec, admin_spec, edit_spec) can fail in full suite runs due to order-dependent Capybara/DB state leakage. Pass when run in isolation.
- Solutions request specs (team puzzle tests) — PG deadlocks from concurrent 2-user simulations. Intermittent in full suite. Pass in isolation.

## Gotchas Encountered
- **UCW letters data contract**: `nil` = void cell, `""` = non-void empty cell, `"A"` = letter. JS sends `"0"` for voids, `" "` for empties. Controller must map correctly (see `update_letters`). MIN_DIMENSION is 4 — test UCWs need at least 4×4.
- **Concurrent agents** can revert shared files. Always re-read before editing if another agent is active.
- `rand(n)` can return 0 for integer n — use `rand(1..n-1)` when 0 is invalid.
- Sass nesting `#id` inside `.class` compiles to descendant selector, not compound. Use `&#id` for same-element.
- `Clue#strip_tags`: ASCII-8BIT strings get double-encoded by Loofah. Encoding guard added.

## Recently Completed
- **Create Dashboard polish (10 findings)**: Added `before_action :ensure_logged_in` (logged-out users now redirect to `account_required_path` instead of inline message). Added `.order(updated_at: :desc)` to both queries. Removed `.try()` wrappers. View rewritten: `row_top_title: 'Your Puzzles'` dark header bar, BEM `.xw-create__section-heading` (font-ui/sm/uppercase/muted matching stats pattern), `.xw-create__count` badge, `.xw-empty-state` for no unpublished puzzles, "New Puzzle" button anchored to unpublished section via `.xw-create__new-btn`. Dead `#unpublished-count`/`#published-count` IDs removed. CSS added to `_components.scss`. New `spec/requests/create_spec.rb` (5 cases). Legacy controller spec updated (anonymous → redirect). 947 specs green, no migration.
- **Stats page rebuild (6-section dashboard)**: Full rewrite of `/stats`. Hero number cards (4 COUNT queries), 3 growth line charts (existing 2 + new puzzles-published), CSS-only horizontal bar chart for grid size distribution, solving activity metrics row (completion rate, avg solvers, hint-free %), popular puzzles leaderboard (top 5 by solver_count), top constructors leaderboard (top 5 by puzzle_count). Progressive disclosure — sections hidden when data insufficient. All queries are indexed COUNT/GROUP BY. Used CSS bars instead of Chart.js for grid sizes (simpler, lighter). BEM `.xw-stats__*` class hierarchy. 3 files touched: controller, view, stylesheet. No JS changes, no migration. 942 specs pass.
- **Info pages polish**: Defined `.xw-hr--accent` (2px accent border-top) in `_components.scss` — Stats page separator was invisible. Flattened Contact from 3 h2 sections to concise prose with inline email + GitHub links and dinkus separator. Added "Browse Puzzles" CTA to FAQ and Contact (matching About). Swapped hardcoded `1.4375rem` row-topper h1 font size for `var(--text-2xl)` token. CSS-only + views. No migration.
- **Edit autosave icon fixes**: Ghost button style (was secondary), removed trailing space from "Saved " text in both edit_funcs.js and solve_funcs.js, added `width: 100%` to `.xw-edit-header` so `margin-left: auto` on `#puzzle-controls` pushes right. Updated view spec (aria-label "Quicksave" → "Save"). CSS + JS + HAML. No migration.
- **Pixel-perfect polish (home + solve + edit)**: per_page 30, BEM load-more class, Courier Prime cells (--font-mono), clue/dropdown font tokens, 5 spacing em→token swaps, dead .clues height deleted, h1 line-height tightened, byline mask-image (no solid-over-texture), meta-to-footer gap, cell z-index renumbered (999-1100 → 0-3), orphaned hr removed, toggle keyboard a11y (visually-hidden + :has(:focus-visible)), --z-panel token. CSS-only + per_page. No migration.
- **Edit Page Frontend Review (13 items)**: JS crash after void toggle (scroll_to_selected guard + cw.editing early-return in corresponding_clue), tool panels reduced from 90% to 45vh (top: 55% desktop, 60% phone), dead settings modal + spin_title + jquery-ui + #tools CSS all removed, phone switch labels shrunk on mobile, number_clues NaN guarded. Vendor jquery-ui-1.10.4.draggable.min.js deleted. 5 modal specs removed. No migration.
- **Home Page Pixel-Perfect Review (10 items)**: Mostly already fixed by prior work. New: `.tab-label` inline-flex for icon+text tabs, `.xw-home__heading` token-based margins replacing inline style, `.xw-hr--flush` border reset, min-height on sparse tab panels. CSS-only, no migration.
- **Account Settings Rebuild (10 phases)**: Single scrollable page replaces 4-tab layout. 3 sections: Profile (email/username editing), Notifications (5 JSONB checkboxes, opt-out model), Account (password change + delete). Anonymize pattern for account deletion — PII stripped, record kept, all FKs valid. 10 views audited for `deleted?` guards. 92 specs green. Migration: 2 columns on users.
- **Edit page save bugs (CRITICAL)**: Fixed 2 data-destroying bugs. Bug 1: `update_letters` mapped empty cells (`" "`) to `nil` (void marker) — now correctly maps to `""`. Bug 2: `save_puzzle()` missing `e.preventDefault()` caused Turbo to intercept `<a href="#">` click and reload page. Also: save button right-aligned, 4 regression specs added, 2 controller specs updated, data repair diagnostic rake task added.
- **Loading feedback system (4 layers)**: Global Turbo nav dimming (`.xw-loading` class on `turbo:click`), `disable_with` on 16 form buttons, solve toolbar `.xw-btn--busy` spinner + `.xw-btn--saved` green pulse, edit pattern search wired to `loading_controller.js`. No migrations.
- **Visual design review (12 fixes)**: Hamburger labels, CTA button text, search placeholder, forgot-password color, empty states, contact page, account tabs, puzzle preview, auth error pages, banner padding, sticky footer, profile stats font.
- **Profile N+1 fix**: 3 precomputed counts in `UsersController#show` → ivars in `_user.html.haml`
- **FriendshipService**: Extracted from `FriendRequestsController`. `.accept` and `.reject` class methods. 8 specs.
- **Error page modernization**: `error.html.haml`, `unauthorized.html.haml`, `account_required.html.haml` — added icons, titles, improved copy.
- **Sessions request specs**: 11 specs covering login/logout/redirect security.
- **NYT Calendar**: Smart init, year nav, puzzle count badge, month index precomputation.

## Deploy Notes (for Deployer)
- Migration `fix_double_encoded_clues` — reverses Ã-signature double-encoding.
- Migration `add_hints_used_to_solutions` — integer column, default 0.
- Migration `add_revealed_indices_to_solutions` — text column (JSON array), default '[]'.
- Migration `add_account_settings_columns_to_users` — `notification_preferences` JSONB + `deleted_at` datetime.
- Run `bundle exec rails repair:void_cells` after deploy to fix "0" string corruption in UCWs.
- Run `bundle exec rails repair:diagnose_void_corruption` after deploy to flag UCWs with >60% voids for manual review.
