# Xword - Crossword Puzzle Application

## Overview

A Rails web app for solving and creating crossword puzzles. Features include:
- Solving crosswords (solo and team-based via ActionCable/WebSockets)
- Creating/publishing user-made crosswords
- NYT crossword importing
- User accounts, friendships, favorites, comments
- Admin panel for content management
- Real-time collaboration via ActionCable + Pusher
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

## Project Structure

```
app/
  assets/javascripts/    # Plain JS (converted from CoffeeScript Feb 2026)
  channels/              # ActionCable channels (messages_channel.rb)
  controllers/
    admin/               # Admin CRUD controllers (crosswords, users, etc.)
    api/                 # JSON API (crosswords, users)
    *.rb                 # Main app controllers
  helpers/               # ApplicationHelper, SwitchHelper
  mailers/               # AdminMailer, UserMailer
  models/
    application_record.rb  # Abstract base class (primary_abstract_class)
    concerns/              # Crosswordable, Publishable, Newyorkable (Examplable unused)
    *.rb                   # 14 models (all inherit from ApplicationRecord)
  uploaders/             # CarrierWave uploaders (AccountPicUploader, PreviewUploader)
  views/                 # HAML templates
config/
  initializers/
    assets.rb            # Sprockets precompile globs (*.css, *.js)
    fog_init.rb          # CarrierWave + fog-aws config (guarded by ENV check)
  application.rb         # config.load_defaults 8.1, autoload_lib, time_zone
  boot.rb                # require 'logger' (kept for clarity)
  environment.rb         # ActiveRecord::Base extensions (skip_callbacks, next_index)
  routes.rb              # All routes
  cable.yml              # ActionCable config
  database.yml           # PostgreSQL config
lib/
  custom_funcs.rb        # time_difference_hash(), missing_this_year(), Integer#left_digits
                         # (manually required in application.rb; excluded from Zeitwerk)
spec/                    # RSpec test suite
  controllers/           # 9 controller specs + admin/
  models/                # 9 model specs
  features/              # 2 integration specs (login, solve)
  factories/             # FactoryBot factories
vendor/
  assets/                # Foundation 5 & 6 JS/CSS
```

## Domain Model

Core entities and their relationships:

- **User** — accounts with authentication (bcrypt), PgSearch for name/username search
- **Crossword** — the main entity; includes Crosswordable, Publishable, Newyorkable concerns
- **UnpublishedCrossword** — draft crosswords with PostgreSQL array columns (letters, potential_words, clues)
- **Cell** — individual cells in a crossword grid
- **Clue** — across/down clues linked to cells
- **Word** — dictionary words with PgSearch full-text search
- **Phrase** — related to words/clues (TODO: undecided usage, may be removed)
- **Solution** — a user's solve attempt for a crossword
- **SolutionPartnering** — links users to team solutions
- **CellEdit** — tracks individual cell edits during solving
- **Comment** — threaded comments on crosswords
- **FavoritePuzzle** — user favorites
- **Friendship** — bidirectional friendships (self-join, no primary key)
- **FriendRequest** — pending friend requests (no primary key)

## Upgrade History

The app was upgraded from Rails 5.1.4 through to 8.1.2 in Feb 2026:

```
Rails:     5.1.4 → 6.1 → 7.0 → 7.2 → 8.0 → 8.1
Ruby:      2.x → 3.1.6 → 3.2.10 → 3.3.10 → 3.4.8
Heroku:    heroku-22 → heroku-24
HAML:      5.2 → 6.4 → 7.2
Sprockets: 3.7 → 4.2
Puma:      5.x → 6.x → 7.x
Redis:     4.0.1 → 5.4.1
CarrierWave: 1.3.4 → 3.1.2
fog-aws:   2.0.0 → 3.33.1
rspec-rails: 4.1.2 → 8.0.3
```

### Key changes during upgrade
- All `belongs_to` with nullable FK columns: added `optional: true`
- `content_tag_for` → `content_tag + dom_id` (removed `record_tag_helper` dependency)
- `render text:` → `render plain:` in 3 controllers
- `include PgSearch` → `include PgSearch::Model` in 3 models
- `cw.try(:preview)` → `cw.preview_url` in `_crossword_tab.html.haml`
- `sass-rails` → `sassc-rails`; `uglifier` → `terser`
- All 12 CoffeeScript files converted to plain JS
- `haml succeed` helper → `content_tag` equivalent (removed in HAML 6)
- `annotate` gem removed (incompatible with Rails 8, dev-only tool)
- `puma ~> 5` → `~> 6` (required for Rack 3 / Rails 8) → `~> 7` (Heroku Router 2.0)
- `gem 'csv'` added explicitly (removed from Ruby 3.4 default gems)
- `httparty` 0.15.7 → 0.24.2 (old version required csv directly)
- `config.active_support.deprecation` removed from dev/test envs (Rails 8 API change)
- `new_framework_defaults.rb` (Rails 5.0 era) and `new_framework_defaults_7_2.rb` deleted
- All 14 models migrated from `ActiveRecord::Base` to `ApplicationRecord`
- CarrierWave: `extension_white_list` → `extension_allowlist`; removed `config.fog_provider` (deprecated)
- Factories: all static values wrapped in blocks; Faker positional args → keyword args
- Controller specs: `get :action, id:` → `get :action, params: { id: }` (Rails 5+ style)
- `rspec-its` gem added (extracted from rspec-core)
- `Procfile` added (`web: bundle exec puma -C config/puma.rb`)
- GitHub Actions CI added (Feb 2026): Postgres 16, Ruby from `.ruby-version`, runs rspec
- **Hotwire migration** (Feb 2026): `turbolinks` + `jquery_ujs` → `turbo-rails` + `stimulus-rails`
  - 13 `.js.erb` files → `.turbo_stream.erb`; 12 `.js.erb` dead code deleted; 5 kept (jQuery AJAX)
  - All `remote: true` forms → `form_with`; method:delete links → `data: { turbo_method: }`
  - `spec_helper.rb`: added `infer_spec_type_from_file_location!` + `Shoulda::Matchers.configure`

### Changes (Mar 2026)
- **Race conditions fixed**: `populate_cells` uses atomic `INSERT … RETURNING id`; team key uses
  `SecureRandom.alphanumeric(12)` + unique DB index + `rescue RecordNotUnique; retry` in controller
- **20 FK indexes added** (migration `20260301031639`): all foreign-key columns on cells, clues,
  comments, crosswords, solutions, solution_partnerings, users (auth_token unique), etc.
- **Signed auth cookies**: `cookies[:auth_token]` → `cookies.signed[:auth_token]` (HMAC-verified);
  session-based auth still works as legacy fallback
- **Test suite**: 0 failures, 15 pending (was 48 failures). Fixes: `belongs_to.optional`,
  `validate_inclusion_of` (was `ensure_inclusion_of`), Faker keyword args, `be true/false` (was
  `be_true/be_false`), `rails-controller-testing` gem added, `:should` syntax enabled in spec_helper

### Deleted files
- `config/initializers/ruby3_compat.rb` — 306 lines of Rails 5.1/Ruby 3.x patches
- `config/initializers/new_framework_defaults.rb` — Rails 5.0 defaults (all baked into load_defaults 8.1)
- `config/initializers/new_framework_defaults_7_2.rb` — all options were commented out

## PostgreSQL-Specific Features

- **Array columns** on `unpublished_crosswords` (letters, potential_words, across_clues, down_clues)
- **PgSearch** full-text search (tsearch with prefix) on Crossword, User, and Word models
- **RANDOM()** for random puzzle selection
- **Sequence queries** (`SELECT last_value FROM <table>_id_seq`) in `ActiveRecord::Base.next_index`
  (defined in `config/environment.rb`; no longer used after populate_cells fix — candidate for removal)
- **plpgsql** extension enabled
- Raw SQL bulk inserts in `Crossword#populate_cells`

## Frontend / Asset Pipeline

Sprockets 4.2 pipeline with manifest at `app/assets/config/manifest.js`:
- **Plain JS** — 12 files (converted from CoffeeScript; crossword interactions, ActionCable, account, global)
- **SASS** via `sassc-rails`
- **jQuery** via `jquery-rails` (required by solve_funcs.js, edit_funcs.js, remotipart)
- **Turbo** via `turbo-rails` — Turbo Drive (page navigation) + Turbo Streams (DOM updates)
- **Stimulus** via `stimulus-rails`
- **Foundation** 5 & 6 (vendored JS/CSS)
- Manifests: `application.js`, `solve.js`, `edit.js`
- **NOTE**: Files calling `$.ajax({ dataType: 'script' })` use `.js.erb` + `format.js` (NOT Turbo Streams):
  `check_cell.js.erb`, `check_completion.js.erb`, `solutions/update.js.erb`,
  `update_letters.js.erb`, `live_search.js.erb`

## Testing

- **Framework**: RSpec with `rspec-rails ~> 8.0` (8.0.3)
- **Factories**: FactoryBot 6.5 (all attributes use block syntax)
- **Database cleaning**: DatabaseCleaner 2.1 with truncation strategy (not transactions)
- **Feature tests**: Capybara `~> 3.0` with CSS selectors (rack-test driver, no JS)
- **Coverage**: SimpleCov `~> 0.22`
- **Matchers**: shoulda-matchers `~> 7.0`
- **its()**: rspec-its 2.0 (extracted from rspec-core)
- **Controller specs**: require `rails-controller-testing` (installed)
- **Pending tests (15)**: published-crossword flows (column removed), HABTM join tables removed,
  login feature specs requiring JS driver

Run tests: `bundle exec rspec`

## Notable Gems and Their Roles

| Gem | Version | Purpose |
|-----|---------|---------|
| `pg` | 1.6.3 | PostgreSQL adapter |
| `pg_search` | 2.3.7 | Full-text search on Crossword, User, Word |
| `active_record_union` | 1.3.0 | UNION queries in ActiveRecord |
| `carrierwave` | 3.1.2 | Image uploads to S3 |
| `fog-aws` | 3.33.1 | AWS S3 backend for CarrierWave |
| `rmagick` | 5.5.0 | Image resizing |
| `pusher` | 1.3.1 | Real-time push notifications |
| `redis` | 5.4.1 | ActionCable WebSocket backend |
| `bcrypt` | 3.1.11 | Password hashing |
| `haml` | 7.2.0 | View templates |
| `will_paginate` | 3.3.1 | Pagination |
| `nilify_blanks` | 1.3.0 | Convert blank strings to NULL |
| `httparty` | 0.24.2 | HTTP client (NYT puzzle fetching) |
| `sassc-rails` | — | SASS/SCSS compilation |
| `terser` | — | JS minification in production |
| `turbo-rails` | 2.0.23 | Hotwire Turbo Drive + Turbo Streams (replaces turbolinks + jquery_ujs) |
| `stimulus-rails` | 1.3.4 | Hotwire Stimulus JS framework |
| `remotipart` | 1.4.4 | Multipart AJAX file uploads (requires jQuery) |
| `jbuilder` | 2.14.1 | JSON API views |
| `rails-controller-testing` | 1.0.5 | Enables get/post in RSpec controller specs |

## Key Commands

```bash
bundle install          # Install dependencies
rails db:create         # Create dev + test databases
rails db:migrate        # Run migrations
rails server            # Start dev server (Puma)
bundle exec rspec       # Run test suite (0 failures, 15 pending)
rails console           # Interactive console
```

## Heroku Deployment

- **App name**: `crosswordcafe`
- **URL**: https://crosswordcafe.herokuapp.com/
- **Stack**: heroku-24 (Ruby 3.4.8)
- **Status**: Live on Rails 8.1.2

Deploy workflow:
```bash
git push origin master && git push heroku master
```

After any Ruby version change: `bundle lock --add-platform x86_64-linux` before pushing.

## Known Technical Debt

1. **`remotipart` 1.4.4** — multipart AJAX file uploads (profile pic); Rails 8 + Turbo compatibility untested
2. **`published` column** removed from Crossword schema; `publish!` and `error_if_published` are no-ops;
   all "published crossword" guards disabled until column is restored
3. **`next_index`** in `config/environment.rb` — no longer used after `populate_cells` atomic SQL rewrite;
   candidate for removal
4. **`Examplable` concern** (`app/models/concerns/examplable.rb`) — not included by any model; dead code
5. **`Phrase` model** (`app/models/phrase.rb`) — TODO: "DECIDE HOW I WILL USE THIS MODEL IF AT ALL!!!"
6. **Feature specs** (login_spec.rb) — home-page and dropdown login flows need a JS-capable Capybara
   driver (e.g. Cuprite); skipped for now
7. **Ruby 3.5** — only preview1 available as of Feb 2026; upgrade when stable
