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
- **Backend Logic Audit (plan #12)**: All 4 should-fixes + 4 suggestions implemented. (S1) Admin actions `admin_fake_win`/`admin_reveal_puzzle` switched from inline `head :forbidden` to `before_action :ensure_admin` — consistent with all other admin actions. Updated 4 request specs (forbidden→redirect). (S2) Already done in #10 (SolutionPartnering unique index + validation). (S3) `Crossword has_many :favorite_puzzles` → `dependent: :destroy`. (S4) `User friendship_ones/twos` → `dependent: :destroy`. (G1) Deleted 8 unused scopes: `:standard`, `:nonstandard`, `:solo`, `:teamed` (Publishable), `:abandoned` (Solution), `:desc_indices`, `:circled`, `:uncircled` (Cell). (G2) Friendship self-guard: `cannot_befriend_self` validation + spec. (G3) Word `:content` presence validation. (G4) Phrase/Word `has_many :clues` → `dependent: :nullify`. 967 examples, 0 failures. One migration (from #10).
- **Test Suite Health (plan #11)**: Batch 1 quick wins. (1) Fixed flaky `live_search` test: replaced `let_it_be` with `let!` in pages_controller_spec.rb — pg_search needs data visible in transaction. (2) Migrated 107 `{ should` → `{ is_expected.to` across 17 spec files. Mechanical find-replace, zero risk. 967 examples, 0 failures.
- **Team Solving UX (plan #10)**: 6 findings implemented. (1) `leave_team` on tab close switched from unreliable `$.ajax` to `navigator.sendBeacon` via `pagehide` event (async XHR is killed during unload). Turbo navigation path keeps existing `$.ajax`. (2) Dead Foundation tooltip in `welcome_teammate` → replaced `has-tip`/`data-tooltip`/`title` with `data-xw-tooltip` (app's CSS tooltip system). `solver_id` attr → `data-solver-id` (standard HTML). Updated `farewell_teammate` selector to match. (3) Added full CSS for invite friend section (`.team-modal__invite`, `__invite-heading`, `__friends-list`, `__friend-btn`, `__friend-name`, `__friend-username`, `__friend-btn--invited`). (4) Anonymous user guard: `roll_call()` and clue click handler skipped when `solve_app.anonymous`. Chat form shows "Sign in to chat" prompt for anon users. (5) Hardcoded `#fdf0e4` chat flash → `.chat--flash` CSS class using `var(--color-accent-light)`. (6) `team-chat__anon-prompt` CSS added.
- **NYT Page / Calendar (plan #6)**: 5 findings implemented. (1) Split query: calendar uses `.pluck(:id, :created_at)` (lightweight, no AR objects), day tabs keep `.to_a` with TODO for pagination at ~1500+. (2) ARIA tab roles added to shared `tabs_controller.js` (`aria-selected` toggle on show), `nyt_view_controller.js` (same), and all HAML templates using tabs (nytimes + home). View toggle and day tabs both have `role="tablist"`, `role="tab"`, `aria-selected`, `aria-controls`, `role="tabpanel"`. (3) Calendar centered with `margin: 0 auto`. (4) `nyt_view_controller.js` wrapped in IIFE. (5) Calendar grid `gap: 2px` annotated with comment.
- **Account Settings (plan #7)**: All items pre-implemented by concurrent agent. Verified: autocomplete attrs on all 7 fields, `slide-close` delegation, `#password-success` removed, `token_tag nil` cleaned up, `multipart: false` removed.
- **User-Made Puzzles (plan #8)**: (1) Added `- title 'User-Made Puzzles'`. (2) Added puzzle count in heading via dynamic `row_top_title`. (3) Added 2 request specs (title, NYT exclusion).
- **Admin Panel (plan #9)**: (1) `clone_user` bare `.find()` → `find_by` with guard. (2) Dead "Mail To" field removed from email form. (3) `wine_comment.haml` renamed to `.html.haml` + title added. (4) Empty `manual_nyt` blank line cleaned up.
- **Forgot/Reset Password review (plan #5)**: 4 remaining items implemented (must-fix and some should-fixes already done in login/signup review). (1) Added `required: true` + `maxlength: User::MAX_PASSWORD_LENGTH` to both reset password fields. (2) Added `autocomplete: 'username'` and `autocomplete: 'email'` to forgot password form fields. (3) Restructured forgot password page to use `row_top_title: 'Retrieve Password'` + `custom_columns: true` + `.xw-col-12.xw-lg-center-6` for width constraint (removed bare `#password-reset-form` div and inline `<h1>`). (4) Removed dead `#password-success` div from both reset_password.html.haml and _account_form.html.haml (controller redirects on success, element never shown). 5 new request specs: resetter valid/invalid/turbo-stream-error, change_password wrong-old-password turbo-stream, change_password validation-failure turbo-stream. 964 examples, 0 failures. No migration.
- **Login / Signup review (plan #4)**: All 8 findings implemented. (1) Turbo Stream `#password-errors` target ID now preserved in replacement content — both `password_errors.turbo_stream.erb` and `wrong_password.turbo_stream.erb` wrap content in `<div id="password-errors">`. (2) Reset password fields have proper `<label>` elements for a11y, removed placeholder-only pattern. (3) Signup form carries `redirect` param via hidden field; `UsersController#create` uses `safe_redirect_path`; validation failure preserves redirect in redirect URL. (4) `SessionsController#new` and `UsersController#new` redirect to root when `@current_user` present. (5) Login page title/heading unified to "Log In". (6) Reset password page has `- title 'Reset Password'`. (7) Dead `forgot_password.scss` deleted + `stylesheet_link_tag` removed. (8) Duplicate legacy controller specs deleted (`sessions_controller_spec.rb`, `users_controller_spec.rb`). 7 new request specs added. 954 examples, 0 failures. No migration.
- **Changelog UX Polish (plan #3)**: All 6 findings implemented. (1) `stylesheet_link_tag 'changelog'` added via `content_for :head` — CSS now loads (timeline, badges, responsive). (2) `strip_category_prefix` method removes leading keyword from displayed message so entries don't stutter ("Fix Fix..." → badge shows "Fix", message shows "Edit page..."). Only strips :fix/:feature/:improve/:polish; :update verbs kept as-is. (3) `SKIP_PATTERNS` constant + `skip_commit?` method filters persona memory, CLAUDE.md, merge commits, review plans before building commits array. `filter_map` replaces `.map` in fetch_from_github. (4) `categorize` now detects test/spec commits before the "Add" pattern — "Add request specs" → :update not :feature. (5) Mobile stacking order fixed: badge → message → SHA (was badge → SHA → message). (6) Disabled pagination buttons changed from `<span>` to `<button disabled>` for a11y. 19 specs (was 14), 0 failures. No migration.
- **Search Page fixes (plan #2)**: Blank query guard (`return if @query.blank?`), `.limit(50)` on all 3 search queries, removed N+1 `word.crosswords.size` from word cards (clue count is sufficient and already eager-loaded). View nil-safe guards (`@words&.any?`). Migrated `should respond_with` → `expect()` in controller specs. Added 4 live_search request specs. 983 examples, 0 failures.
- **New Puzzle Form polish (plan items 1–4, 6)**: Changed create failure from `redirect_to` → `render :new, status: :unprocessable_entity` (preserves form state). Added `disable_with: 'Creating…'` on submit. Removed void toggle click handler + cursor:pointer from preview grid (was cosmetic — data never sent). Added `aria-hidden` to preview. Deleted vendor `spin.min.js`, replaced with CSS `.xw-spinner` overlay (`.xw-newcw-overlay`). Moved JS include into `content_for :head`. Added inline `.xw-alert--error` error display. 5 new request specs. 979 examples, 0 failures. No migration.
