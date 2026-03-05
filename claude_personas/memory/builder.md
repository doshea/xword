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
- `.xw-puzzle-grid .xw-tabs__nav` CSS is NOT dead — class used in 4 views. (Renamed from `.puzzle-tabs` in BEM sprint.)
- jQuery `.position()` returns coords relative to nearest positioned ancestor — grep for `.position()` and `.offset()` when changing CSS `position` properties.
- Admin tools: `@current_user&.is_admin` guard → `head :forbidden`. Wrapped in `- if is_admin?` in HAML.
- Reveal Puzzle JS uses direct `.text()` not `set_letter()` to avoid N team broadcasts.
- **Stats page**: Chart.js v4 vendored locally (`chart.umd.min.js`, loaded via `javascript_include_tag` in `content_for :head`), only on stats page. Stimulus `stats` controller renders charts. `pointRadius: 0` with `pointHitRadius: 8` for 1000+ data points.
- **Solve timer**: Client-side `setInterval(1s)` in `solve_funcs.js`. Uses `solve_app.started_at` (epoch ms from `solution.created_at`). Freezes on win or if `is_complete` is true on load. Format: `MM:SS` / `H:MM:SS` / `Dd H:MM:SS`.
- **Next puzzle on win**: `@next_puzzle` set in `check_completion` controller action. Uses subquery `Crossword.where(id: Crossword.new_to_user(...))` to avoid PG `DISTINCT + ORDER BY RANDOM()` conflict.

## Known Flakes
- JS feature specs (login_spec, home_tabs_spec, admin_spec, edit_spec) can fail in full suite runs due to order-dependent Capybara/DB state leakage. Pass when run in isolation.

## Gotchas Encountered
- **Concurrent agents** can revert shared files. Always re-read before editing if another agent is active.
- `rand(n)` can return 0 for integer n — use `rand(1..n-1)` when 0 is invalid.
- Sass nesting `#id` inside `.class` compiles to descendant selector, not compound. Use `&#id` for same-element.
- `Clue#strip_tags`: ASCII-8BIT strings get double-encoded by Loofah. Encoding guard added.

## Recently Completed
- **Profile N+1 fix**: 3 precomputed counts in `UsersController#show` → ivars in `_user.html.haml`
- **FriendshipService**: Extracted from `FriendRequestsController`. `.accept` and `.reject` class methods. 8 specs.
- **Error page modernization**: `error.html.haml`, `unauthorized.html.haml`, `account_required.html.haml` — added icons, titles, improved copy.
- **Sessions request specs**: 11 specs covering login/logout/redirect security.
- **NYT Calendar**: Smart init, year nav, puzzle count badge, month index precomputation.

## Deploy Notes (for Deployer)
- Migration `fix_double_encoded_clues` — reverses Ã-signature double-encoding.
- Migration `add_hints_used_to_solutions` — integer column, default 0.
- Migration `add_revealed_indices_to_solutions` — text column (JSON array), default '[]'.
- Run `bundle exec rails repair:void_cells` after deploy to fix corrupted UCWs.
