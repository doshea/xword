# Builder Memory

## Workflow

1. **Pick a job from `shared.md`** → timestamp it: `Picked up by Builder at YYYY-MM-DD HH:MM`
2. If already timestamped within 15 min, **stop** — another Builder has it
3. **Read the plan file** for full details (don't rely on the shared.md summary)
4. Implement → `bundle exec rspec` → commit → move item to "Pending Deploy" on shared.md

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
- `.xw-prose a` (0,1,1) overrides `.xw-btn` (0,1,0). Fix: `.xw-prose a:not(.xw-btn)`.
- HAML `!=` for unescaped HTML (e.g. `%p!= empty_message` or `!= "text #{link_to ...}."`).
- HAML unicode: `'\u2026'` is LITERAL. Must use `"\u2026"` (double quotes).
- HAML 7.2: can't use `- end` or `case` for value assignment. Use `if/elsif` or hash lookup.
- `.xw-nav__label`: hidden desktop, shown mobile. For icon buttons needing text in hamburger.
- Sticky footer: `body flex-column` + `#body flex: 1 0 auto`.
- `.xw-puzzle-grid .xw-tabs__nav` is NOT dead — used in 4 views.
- jQuery `.position()` relative to nearest positioned ancestor — grep when changing CSS `position`.
- Edit tool panels: `top: 100%` (closed) / `top: 55%` (open). `.bottom-button` at `top: -1.5em`.
- Edit `corresponding_clue()`: edit uses `data-index`, solve uses `data-cell-num`. Guarded with `if (cw.editing) return`.
- Stats: Chart.js v4 vendored locally, Stimulus controller, only on stats page.
- Loading: `turbo:click` → `.xw-loading`; forms use `disable_with`; AJAX toolbar uses `.xw-btn--busy`.
- `_check_trigger()` returns "Check ▾" dropdown trigger — shared by 6 functions.
- `solution_choice.js`: programmatic `Turbo.visit` doesn't fire `turbo:click`, add `.xw-loading` manually.

## Known Flakes
- JS feature specs can fail in full suite (order-dependent Capybara state). Pass in isolation.
- Solutions team specs — PG deadlocks from concurrent 2-user sims. Pass in isolation.

## Gotchas
- **UCW letters**: `nil` = void, `""` = empty, `"A"` = letter. JS sends `"0"`/`" "`. Map correctly.
- **Concurrent agents** can revert shared files. Re-read before editing.
- `rand(n)` can return 0 — use `rand(1..n-1)` when 0 is invalid.
- Sass `#id` inside `.class` = descendant selector. Use `&#id` for same-element compound.
- `Clue#strip_tags`: ASCII-8BIT → double-encoded by Loofah. Encoding guard exists.

## Pre-existing Failures (not from changelog work)
- 2 `PagesController` controller spec failures: anonymous + logged-in home redirect (from unstaged welcome page changes)
- 5 Capybara feature spec failures: accessibility, login, edit, home_tabs (browser-dependent flakes)
- These were present before changelog changes and unrelated to them.

## Recently Completed
- **Login / Signup review (plan #4)**: All 8 findings implemented. (1) Turbo Stream `#password-errors` target ID now preserved in replacement content — both `password_errors.turbo_stream.erb` and `wrong_password.turbo_stream.erb` wrap content in `<div id="password-errors">`. (2) Reset password fields have proper `<label>` elements for a11y, removed placeholder-only pattern. (3) Signup form carries `redirect` param via hidden field; `UsersController#create` uses `safe_redirect_path`; validation failure preserves redirect in redirect URL. (4) `SessionsController#new` and `UsersController#new` redirect to root when `@current_user` present. (5) Login page title/heading unified to "Log In". (6) Reset password page has `- title 'Reset Password'`. (7) Dead `forgot_password.scss` deleted + `stylesheet_link_tag` removed. (8) Duplicate legacy controller specs deleted (`sessions_controller_spec.rb`, `users_controller_spec.rb`). 7 new request specs added. 954 examples, 0 failures. No migration.
- **Changelog UX Polish (plan #3)**: All 6 findings implemented. (1) `stylesheet_link_tag 'changelog'` added via `content_for :head` — CSS now loads (timeline, badges, responsive). (2) `strip_category_prefix` method removes leading keyword from displayed message so entries don't stutter ("Fix Fix..." → badge shows "Fix", message shows "Edit page..."). Only strips :fix/:feature/:improve/:polish; :update verbs kept as-is. (3) `SKIP_PATTERNS` constant + `skip_commit?` method filters persona memory, CLAUDE.md, merge commits, review plans before building commits array. `filter_map` replaces `.map` in fetch_from_github. (4) `categorize` now detects test/spec commits before the "Add" pattern — "Add request specs" → :update not :feature. (5) Mobile stacking order fixed: badge → message → SHA (was badge → SHA → message). (6) Disabled pagination buttons changed from `<span>` to `<button disabled>` for a11y. 19 specs (was 14), 0 failures. No migration.
- **Search Page fixes (plan #2)**: Blank query guard (`return if @query.blank?`), `.limit(50)` on all 3 search queries, removed N+1 `word.crosswords.size` from word cards (clue count is sufficient and already eager-loaded). View nil-safe guards (`@words&.any?`). Migrated `should respond_with` → `expect()` in controller specs. Added 4 live_search request specs. 983 examples, 0 failures.
- **New Puzzle Form polish (plan items 1–4, 6)**: Changed create failure from `redirect_to` → `render :new, status: :unprocessable_entity` (preserves form state). Added `disable_with: 'Creating…'` on submit. Removed void toggle click handler + cursor:pointer from preview grid (was cosmetic — data never sent). Added `aria-hidden` to preview. Deleted vendor `spin.min.js`, replaced with CSS `.xw-spinner` overlay (`.xw-newcw-overlay`). Moved JS include into `content_for :head`. Added inline `.xw-alert--error` error display. 5 new request specs. 979 examples, 0 failures. No migration.
