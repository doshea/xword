# Xword — Crossword Café

## Working Style

**Think holistically before changing code.** When fixing a bug or implementing a feature:
1. Search for the same pattern elsewhere in the codebase — fix all instances together, not just the one that surfaced.
2. Trace the full impact: HTML, CSS, JS, and tests are a unit. Verify that class names, selectors, and DOM structure stay consistent across all layers.
3. Add or update specs to cover the changed behavior.
4. If a broader fix carries risk, flag it before proceeding.

## Development Rules

- Run `bundle exec rspec` after non-trivial changes. "Should work" is not "does work."
- Prefer ActiveRecord queries over raw SQL. If raw SQL is necessary, add a comment explaining why.
- Test behavior, not implementation details. Don't test that Rails works.
- New gems, patterns, or architectural layers are fine when they improve app longevity and are manageable long-term — but get user buy-in first.
- Business logic belongs in models or service objects, not controllers. Controllers handle request/response only. If you're writing more than ~10 lines of logic in a controller action, it should be extracted.

## Overview

A Rails web app for solving and creating crossword puzzles. Features include:
- Solving crosswords (solo and team-based via ActionCable/WebSockets)
- Creating/publishing user-made crosswords
- NYT crossword importing
- User accounts, friendships, favorites, comments
- Admin panel for content management
- Real-time collaboration via ActionCable
- Image uploads to AWS S3 via CarrierWave + Fog

## Tech Stack

| Component | Version | Notes |
|-----------|---------|-------|
| Ruby | 3.4.8 | Pinned in `.ruby-version` and `Gemfile` |
| Rails | 8.1.2 | `config.load_defaults 8.1` |
| PostgreSQL | Any modern version | Uses `pg ~> 1.2` gem |
| Redis | 5.4.1 | Required for ActionCable |
| Heroku | heroku-24 | Ubuntu 24.04 LTS |
| Puma | 7.2.0 | Declared in Procfile |
| HAML | 7.2.0 | Views use HAML 7 |
| Sprockets | 4.2.2 | Asset pipeline; manifest at `app/assets/config/manifest.js` |
| Turbo | 2.0.23 | Turbo Drive (page navigation) + Turbo Streams (DOM updates) |
| Stimulus | 1.3.4 | JS framework for controllers |
| jQuery | via `jquery-rails` | Required by solve_funcs.js, edit_funcs.js, remotipart |

## Project Structure

```
app/
  assets/javascripts/    # Plain JS (converted from CoffeeScript Feb 2026)
  channels/              # ActionCable channels (messages_channel.rb, teams_channel.rb)
  controllers/
    admin/               # Admin CRUD controllers inherit from Admin::BaseController
    api/                 # JSON API (crosswords, users)
    *.rb                 # Main app controllers
  helpers/               # ApplicationHelper (icon helper, etc.), SwitchHelper
  mailers/               # AdminMailer, UserMailer
  models/
    application_record.rb  # Abstract base class (primary_abstract_class)
    concerns/              # Crosswordable, Publishable, Newyorkable
    *.rb                   # 14 models (all inherit from ApplicationRecord)
  uploaders/             # CarrierWave uploaders (AccountPicUploader, PreviewUploader)
  views/                 # HAML templates
config/
  environment.rb         # ActiveRecord::Base extensions (skip_callbacks, next_index)
  routes.rb              # All routes
lib/
  custom_funcs.rb        # Utility functions (manually required; excluded from Zeitwerk)
spec/
  requests/              # Request specs (preferred for new HTTP-layer tests)
  controllers/           # Legacy controller specs (don't add new ones here)
  models/                # Model specs
  features/              # Capybara + Cuprite JS integration specs
  factories/             # FactoryBot factories
  support/auth_helpers.rb  # AuthHelpers (controller) + RequestAuthHelpers (request)
```

## Domain Model

Core entities and their relationships:

- **User** — accounts with authentication (bcrypt), PgSearch for name/username search
- **Crossword** — the main entity; includes Crosswordable, Publishable, Newyorkable concerns
- **UnpublishedCrossword** — draft crosswords with PostgreSQL array columns (letters, clues)
- **Cell** — individual cells in a crossword grid
- **Clue** — across/down clues linked to cells; has `crosswords_by_title` aggregation method
- **Word** — dictionary words with PgSearch full-text search; has `crosswords_by_title` method
- **Solution** — a user's solve attempt for a crossword
- **SolutionPartnering** — links users to team solutions
- **Comment** — threaded comments on crosswords (self-referential via `base_comment_id`)
- **FavoritePuzzle** — user favorites
- **Friendship / FriendRequest** — bidirectional friendships (self-join, no primary key)

**Dead or undecided models** (candidates for removal):
- **Phrase** — TODO from original author; not used by any code
- **CellEdit** — tracks individual cell edits; unused in current UI

## Architecture Direction

The app was upgraded from Rails 5.1 to 8.1 in Feb-Mar 2026. The front-end modernization
(Foundation removal, design tokens, accessibility, mobile responsiveness) is complete. The
next phase of improvement is **backend architecture cleanup**:

### Principles

1. **Extract service objects for multi-step operations.** Controllers should call a service,
   not orchestrate a pipeline. Priority targets:
   - `UnpublishedCrosswordsController#publish` (~40 lines of crossword construction)
   - `Newyorkable` concern (100+ lines of ETL disguised as a model concern)
   - Team broadcast logic in `SolutionsController`

2. **Push authorization into models.** `SolutionsController` has 3 custom before_actions
   reimplementing access control. A `Solution#accessible_by?(user)` method would be testable,
   reusable, and keep controllers thin.

3. **Guard against nil at system boundaries.** Several model methods assume associations exist
   without checking (e.g., `get_mirror_cell` return value, `Newyorkable` assuming the nytimes
   user exists). Add guards where data crosses trust boundaries; trust internal code paths.

4. **Delete dead code.** Don't keep unused models, concerns, or factories "just in case."
   If it's not called, it's not documentation — it's confusion.

### Known Runtime Risks

These are bugs or crash paths that exist in production code today:

1. **`Solution#percent_complete`** — division by zero if `nonvoid_letter_count` is 0
2. **`Crossword#randomize_letters_and_voids`** — calls `.is_void!` on nil `get_mirror_cell` return
3. **`Newyorkable#add_nyt_puzzle`** — NPE if `User.find_by_username('nytimes')` returns nil
4. **`Newyorkable` HTTP calls** — no timeout on HTTParty requests; can hang a Puma thread
5. **`UsersController#update`** — bare `User.find(params[:id])` without RecordNotFound rescue
6. **`CommentsController#add_comment`** — bare `Crossword.find(params[:id])` without rescue

## Frontend / Asset Pipeline

Sprockets 4.2 pipeline with manifest at `app/assets/config/manifest.js`:
- **Plain JS** — 12 files (crossword interactions, ActionCable, account, global)
- **SASS** via `sassc-rails`; design tokens in `_design_tokens.scss`
- **Turbo** — Turbo Drive (page navigation) + Turbo Streams (DOM updates)
- **Stimulus** — nav, dropdown, tab, alert controllers
- Manifests: `application.js`, `solve.js`, `edit.js`
- 5 files use `.js.erb` + `format.js` (jQuery AJAX, NOT Turbo Streams):
  `check_cell`, `check_completion`, `solutions/update`, `update_letters`, `live_search`

**JS/CSS coupling hazard**: jQuery `.position()` returns coordinates relative to the nearest
positioned ancestor. If CSS refactoring removes `position` from an ancestor, JS scroll/position
math silently breaks. When changing CSS `position` properties, grep for `.position()` and
`.offset()` in JS to check for coupling.

## Visual Design

**When asked about style, aesthetics, or visual design of this app, always use the `frontend-design`
skill for assessment and recommendations before proposing changes.**

### Design Philosophy

Cozy "paper on wood" — a crossword worksheet sitting on a cafe table. The aesthetic is editorial
warmth, not sterile web app. Key colors: **black, white, forest green, warm wood tones**. The
existing palette (warm near-blacks, cream surfaces, tan borders, green accents) is intentional
and should be refined, not replaced.

Typography: Playfair Display (editorial serif headings), Lora (readable serif body/clues),
DM Sans (clean sans for UI chrome), Courier Prime (monospace for cells).

### Design System

All visual properties use CSS custom properties defined in `_design_tokens.scss`. Never introduce
hardcoded colors, font stacks, or shadows — use existing tokens or add new ones to the token file.

Key patterns established:
- BEM naming for components (`xw-comment`, `xw-reply`, `xw-btn`, `xw-alert`)
- `xw-` prefix for all custom CSS Grid classes
- Ghost buttons (no border) for toolbar actions
- Warm cream `--color-surface-alt` for nested paper-within-paper containers
- `span.clue-num` with `--color-text-muted` for clue numbers on both pages

### Design Status

The front-end modernization is complete (Foundation fully removed, 21 polish versions).
Primary pages (solve, edit) are polished. Secondary pages (home, search, profile, login) are
tokenized and functional. Remaining opportunities:
- Tablet range (768-1024px) refinements
- About / FAQ / Contact visual treatment
- Admin panel design polish (low priority)

## Testing

Run tests: `bundle exec rspec`  — ~620 examples, 0 failures

### Stack

| Tool | Purpose |
|------|---------|
| RSpec 8.0.3 | Test framework |
| FactoryBot 6.5 | Test data (block syntax) |
| DatabaseCleaner 2.1 | Transactions for unit specs, truncation for `js: true` |
| Capybara + Cuprite | Headless Chrome for JS feature specs (`js: true`) |
| SimpleCov | Coverage reporting |
| shoulda-matchers 7.0 | Association/validation one-liners |

### Auth Helpers

Two modules in `spec/support/auth_helpers.rb`:
- **`AuthHelpers`** — for controller specs: `log_in(user)` sets `session[:user_id]` directly
- **`RequestAuthHelpers`** — for request specs: `log_in_as(user)` performs real POST to `/login`
  - `TEST_PASSWORD` constant defined here; used by `:with_test_password` factory trait
  - Auto-included for `type: :request` specs via `spec_helper.rb`

### Writing Tests

**Syntax**: `expect()` only. No `should`, no `subject.stub(...)`, no `rspec-its`.

**New HTTP specs must be request specs** (`type: :request`), not controller specs.
Use `get '/path'` style, not `get :action, params:`. Controller specs are legacy.

**Test behavior, not markup.** View specs assert semantic HTML and accessibility, not CSS
classes or DOM nesting depth. If the class name changes but the page works, the test shouldn't break.

**Model specs should test business logic.** Validations and associations are a baseline; the
real value is testing methods that compute, transform, or make decisions.

**Factories should be used or deleted.** If a record is always sourced from an association
(cells from crossword), a standalone factory is dead code.

**No empty placeholder specs.** Don't scaffold empty `context`/`describe` blocks for future work.

**Don't test broken state as expected behavior.** If an action raises `MissingExactTemplate`,
fix it — don't write a spec asserting the error.

### Test Patterns (reference for writing new specs)

```ruby
# Request spec auth
let(:user) { create(:user, :with_test_password) }
before { log_in_as(user) }

# Controller spec auth
let(:user) { create(:user) }
before { log_in(user) }

# Turbo Stream actions (controller specs)
before { request.accept = Mime[:turbo_stream].to_s }

# jQuery AJAX actions (controller/request specs)
headers: { 'Accept' => 'text/javascript', 'X-Requested-With' => 'XMLHttpRequest' }

# Cells from crossword (always get a non-void cell)
let(:cell) { crossword.cells.reject(&:is_void).first }

# Clues from crossword
let(:clue) { crossword.cells.find(&:across_clue).across_clue }

# Blank solution letters (spaces for letters, underscores for voids)
let(:blank_letters) { crossword.letters.gsub(/[^_]/, ' ') }

# External HTTP calls — always stub
allow(Word).to receive(:word_match).and_return([...])
allow(UserMailer).to receive_message_chain(:reset_password_email, :deliver_now)
```

## PostgreSQL-Specific Features

- **Array columns** on `unpublished_crosswords` (letters, potential_words, across_clues, down_clues)
- **PgSearch** full-text search (tsearch with prefix) on Crossword, User, and Word models
- **RANDOM()** for random puzzle selection
- **plpgsql** extension enabled
- Raw SQL bulk inserts in `Crossword#populate_cells` (atomic `INSERT ... RETURNING id`)
- `Crossword` has a `default_scope -> { order(created_at: :desc) }` — be aware this
  affects all queries; use `.unscoped` or `.reorder` when it's unwanted

## Key Commands

```bash
bundle install          # Install dependencies
rails db:create         # Create dev + test databases
rails db:migrate        # Run migrations
rails server            # Start dev server (Puma)
bundle exec rspec       # Run test suite (~620 examples, 0 failures)
rails console           # Interactive console
```

## Deployment

- **App name**: `crosswordcafe`
- **URL**: https://crosswordcafe.herokuapp.com/
- **Stack**: heroku-24 (Ruby 3.4.8)

```bash
git push origin master && git push heroku master
```

After any Ruby version change: `bundle lock --add-platform x86_64-linux` before pushing.

## History

The app was originally built on Rails 5.1 / Ruby 2.x and upgraded to Rails 8.1 / Ruby 3.4
in Feb-Mar 2026. Key milestones:

- **Framework upgrade**: Rails 5.1 → 6.1 → 7.0 → 7.2 → 8.0 → 8.1; Ruby 2.x → 3.4.8
- **Hotwire migration**: turbolinks + jquery_ujs → turbo-rails + stimulus-rails
- **Pusher → ActionCable**: real-time team collaboration moved to ActionCable; pusher gem removed
- **Front-end overhaul**: Foundation removed entirely (6 phases); replaced with custom design
  tokens, CSS Grid, Lucide SVGs, Stimulus controllers, native `<dialog>` modals
- **Accessibility audit**: semantic HTML, heading hierarchy, ARIA labels, keyboard navigation
- **Mobile responsiveness**: phone (<640px) and XL (1280px+) breakpoints
- **Test suite**: ~620 examples covering controllers, models, requests, features, views
- **Security**: signed auth cookies, atomic SQL for race conditions, FK indexes

## Technical Debt

### Active (should be addressed)

1. **`remotipart` 1.4.4** — multipart AJAX file uploads (profile pic); Rails 8 + Turbo
   compatibility untested. jQuery dependency.
2. **`published` column removed** from Crossword schema; `publish!` and `error_if_published`
   are no-ops; all "published crossword" guards disabled until column is restored.
3. **`Newyorkable` concern** — 100+ lines of ETL (HTTP calls, JSON parsing, record creation)
   living in a model concern. Should be a service object. Has no timeout on HTTP calls.
4. **`UnpublishedCrosswordsController#publish`** — 40 lines of crossword construction logic
   in the controller. Should be a service object.
5. **`SolutionsController` auth duplication** — 3 custom before_actions reimplementing access
   control that should be a model method (`Solution#accessible_by?`).
6. **`Crossword` default scope** — `order(created_at: :desc)` applied to all queries implicitly.

### Dead code (safe to delete)

1. **`Examplable` concern** (`app/models/concerns/examplable.rb`) — not included by any model
2. **`Phrase` model** (`app/models/phrase.rb`) — unused; `phrase_id` FK on Clue is always nil
3. **`next_index`** in `config/environment.rb` — unused after `populate_cells` atomic rewrite
4. **`:clue` factory** (`spec/factories/clue_factory.rb`) — 0 uses in any spec
5. **`User.with_valid_reset_token` scope** — superseded by Rails 8.1 signed password reset tokens

### Low priority

1. **Ruby 3.5** — upgrade when stable release is available
2. **Missing `inverse_of`** on several `belongs_to` associations
3. **`Comment` factory** missing associations (user, crossword) — all tests assign manually

## Notable Gems

| Gem | Purpose |
|-----|---------|
| `pg` / `pg_search` | PostgreSQL adapter + full-text search |
| `carrierwave` + `fog-aws` + `rmagick` | Image uploads to S3 with resizing |
| `redis` | ActionCable WebSocket backend |
| `bcrypt` | Password hashing |
| `haml` | View templates |
| `will_paginate` | Pagination |
| `httparty` | HTTP client (NYT puzzle fetching) |
| `turbo-rails` + `stimulus-rails` | Hotwire (Turbo Drive/Streams + Stimulus) |
| `remotipart` | Multipart AJAX file uploads (requires jQuery) |
| `jbuilder` | JSON API views |
| `cuprite` | Headless Chrome for Capybara JS specs |
