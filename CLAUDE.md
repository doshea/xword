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
| Ruby | 3.1.6 | Pinned in `.ruby-version` and `Gemfile` |
| Rails | 5.1.4 | Very old — requires extensive monkey-patches for Ruby 3.x |
| PostgreSQL | Any modern version | Uses `pg ~> 1.2` gem |
| Redis | — | Required for ActionCable |

**This is a Rails 5.1.4 app running on Ruby 3.1.6.** These versions are not natively compatible. The codebase contains ~300 lines of monkey-patches to bridge the kwargs incompatibilities between them. Those patches are complete and the app is fully deployed and running. See the "Ruby 3.x Compatibility Patches" section below.

## Project Structure

```
app/
  assets/javascripts/    # CoffeeScript + plain JS (Sprockets pipeline)
  channels/              # ActionCable channels (messages_channel.rb)
  controllers/
    admin/               # Admin CRUD controllers (crosswords, users, etc.)
    api/                 # JSON API (crosswords, users)
    *.rb                 # Main app controllers
  helpers/               # ApplicationHelper, SwitchHelper
  mailers/               # AdminMailer, UserMailer
  models/
    concerns/            # Crosswordable, Publishable, Examplable, Newyorkable
    *.rb                 # 14 models (see Domain Model below)
  uploaders/             # CarrierWave uploaders (AccountPicUploader, PreviewUploader)
  views/                 # HAML templates
config/
  initializers/
    ruby3_compat.rb      # *** CRITICAL: 200+ lines of Rails 5.1 / Ruby 3.x patches ***
    new_framework_defaults.rb  # Rails 5.0 migration defaults (not yet flipped)
  application.rb         # More Ruby 3.x patches (ActiveRecord::Type, MiddlewareStack)
  boot.rb                # pg gem version constraint hack
  environment.rb         # ActiveRecord::Base extensions (skip_callbacks, next_index)
  routes.rb              # All routes
  cable.yml              # ActionCable config
  database.yml           # PostgreSQL config
lib/
  custom_funcs.rb        # time_difference_hash(), missing_this_year(), Integer#left_digits
spec/                    # RSpec test suite
  controllers/           # 9 controller specs + admin/
  models/                # 9 model specs
  features/              # 2 integration specs (login, solve)
  factories/             # FactoryGirl factories
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
- **Phrase** — related to words/clues
- **Solution** — a user's solve attempt for a crossword
- **SolutionPartnering** — links users to team solutions
- **CellEdit** — tracks individual cell edits during solving
- **Comment** — threaded comments on crosswords
- **FavoritePuzzle** — user favorites
- **Friendship** — bidirectional friendships (self-join, no primary key)
- **FriendRequest** — pending friend requests (no primary key)

## Ruby 3.x Compatibility Patches

**This is the most important thing to understand about this codebase.**

Rails 5.1.4 was written for Ruby 2.x, which allowed passing a Hash as the last positional argument to a method expecting keyword args. Ruby 3.0+ made this an error. The app patches Rails internals in four locations. **All patches are in place and the app runs correctly — no further Ruby 3.x fixes are needed.**

The core problem pattern appears in three forms:
1. `method(hash)` where `method` declares only `**kwargs` — raises "given 1, expected 0"
2. `method(*args)` captures a trailing kwargs hash into `*args`, then `super` passes it as a positional arg to a kwargs-only parent — raises "given N, expected N-1"
3. ActiveSupport `delegate` and `helper_method` generate `(*args, &block)` wrappers, swallowing kwargs into positional args before forwarding

### `config/boot.rb`
- **PgGemVersionFix**: Rails 5.1.4 hardcodes `gem "pg", "~> 0.18"` which rejects pg 1.x. This intercepts `Kernel#gem` to relax the constraint to `>= 0.18, < 2.0`.

### `config/application.rb`
- **ActiveRecord::Type.add_modifier**: Fixes kwargs forwarding for the PostgreSQL adapter.
- **ActionDispatch::MiddlewareStack::Middleware#build**: Splats trailing keyword hash from `*args`.

### `config/initializers/ruby3_compat.rb` (~306 lines)
Patches these Rails internals:
- `ActiveModel::Type::Value#initialize` — positional Hash → kwargs (fixes all type subclasses)
- `PostgreSQL::OID::SpecializedString#initialize` — `super(**options)`
- `SchemaStatements#create_table_definition` — captures `**kwargs` separately
- `PostgreSQLAdapter#create_table_definition` — same
- `TableDefinition#new_column_definition` — accepts both positional Hash and kwargs
- `TableDefinition` column type methods (string, integer, etc.) — extracts trailing Hash from `*args`
- `TableDefinition#references` / `belongs_to` — splats kwargs to `ReferenceDefinition.new`
- `Transaction#initialize` — handles extra positional Hash for `run_commit_callbacks`
- `AbstractAdapter#create_table` — positional Hash → kwargs
- `AbstractAdapter#add_index_options` — positional Hash → kwargs
- `AbstractAdapter#transaction` — positional Hash → kwargs
- `AbstractAdapter#type_to_sql` — positional Hash → kwargs
- `PostgreSQLAdapter#type_to_sql` — same, with `array:` support
- `SchemaStatements#quoted_columns_for_index` — positional Hash → kwargs
- `SchemaStatements#add_options_for_index_columns` — same (called by above)
- `SchemaStatements#add_index_sort_order` — same (called by above)
- `AbstractController::Helpers::ClassMethods#helper_method` — overrides the generator to emit `(*args, **kwargs, &blk)` forwarders instead of `(*args, &blk)`, fixing all view helpers backed by kwargs-only controller methods (e.g. `form_authenticity_token`); re-registers all existing helpers
- `ActionView::ViewPaths#template_exists?` — bypasses the `delegate`-generated `(*args, &block)` wrapper so `variants:` kwarg reaches `LookupContext#exists?` correctly instead of landing in the `partial` parameter

### `config/environment.rb`
- `ActiveRecord::Base.skip_callbacks` — class-level accessor used in tests
- `ActiveRecord::Base.next_index` — queries PostgreSQL sequences directly via raw SQL

**If upgrading Rails, all of these patches can and should be removed.** They exist solely to bridge the Ruby 2.x → 3.x kwargs gap in Rails 5.1.4.

## PostgreSQL-Specific Features

The app uses these Postgres-specific features:
- **Array columns** on `unpublished_crosswords` (letters, potential_words, across_clues, down_clues)
- **PgSearch** full-text search (tsearch with prefix) on Crossword, User, and Word models
- **RANDOM()** for random puzzle selection
- **Sequence queries** (`SELECT last_value FROM <table>_id_seq`) in `ActiveRecord::Base.next_index`
- **plpgsql** extension enabled
- Raw SQL bulk inserts in `Crossword#populate_cells`

No JSONB, hstore, triggers, stored procedures, materialized views, or PostGIS.

## Frontend / Asset Pipeline

Uses Rails 5.1 Sprockets pipeline:
- **CoffeeScript** — 12 `.coffee` files (crossword interactions, ActionCable channels, account, global)
- **SASS** via `sass-rails`
- **jQuery** via `jquery-rails`
- **Turbolinks**
- **Foundation** 5 & 6 (vendored JS/CSS)
- Plain JS files: `solve.js`, `edit.js`

## Testing

- **Framework**: RSpec with `rspec-rails`
- **Factories**: FactoryGirl (not FactoryBot — predates the rename)
- **Database cleaning**: DatabaseCleaner with truncation strategy (not transactions)
- **Feature tests**: Capybara with CSS selectors
- **Coverage**: SimpleCov ~0.7.1 (very old)
- **Matchers**: shoulda-matchers
- **Custom metadata tags**: `:dirty_inside` (skip DB cleaning), `:skip_callbacks`
- **Transactional fixtures**: disabled

Run tests: `bundle exec rspec`

## Notable Gems and Their Roles

| Gem | Purpose |
|-----|---------|
| `pg ~> 1.2` | PostgreSQL adapter |
| `pg_search` | Full-text search on Crossword, User, Word |
| `active_record_union` | UNION queries in ActiveRecord |
| `carrierwave` + `fog` + `rmagick` | Image uploads to S3 with resizing |
| `pusher` | Real-time push notifications |
| `puma` + `redis` | ActionCable WebSocket server |
| `bcrypt-ruby` | Password hashing (old gem name; now just `bcrypt`) |
| `haml` | View templates |
| `will_paginate ~> 3.0` | Pagination |
| `nilify_blanks` | Convert blank strings to NULL |
| `record_tag_helper` | `content_tag_for` helper (removed in Rails 6) |
| `httparty` | HTTP client (NYT puzzle fetching) |

## Key Commands

```bash
bundle install          # Install dependencies
rails db:create         # Create dev + test databases
rails db:migrate        # Run migrations
rails server            # Start dev server (Puma)
bundle exec rspec       # Run test suite
rails console           # Interactive console
```

## Heroku Deployment

- **App name**: `crosswordcafe`
- **URL**: https://crosswordcafe.herokuapp.com/
- **Stack**: Heroku-22 (Ruby 3.1.6)
- **Status**: Live and running — all pages return 200

Deploy and test workflow:
```bash
git push origin master && git push heroku master
heroku run "bundle exec rails db:migrate 2>&1" --app crosswordcafe
```

## Known Technical Debt

1. **Rails 5.1.4** — 8+ years old, EOL, requires extensive monkey-patching for Ruby 3.x
2. **FactoryGirl** — renamed to FactoryBot years ago
3. **CoffeeScript** — deprecated, should be converted to plain JS
4. **SimpleCov ~0.7.1** — extremely old version
5. **`fog`** — monolithic gem; should use `fog-aws` instead
6. **`bcrypt-ruby`** — old name; modern gem is `bcrypt`
7. **`record_tag_helper`** — removed from Rails 6+
8. **`new_framework_defaults.rb`** — Rails 5.0 migration defaults never flipped to new values
9. **No CI/CD** — no GitHub Actions, Travis, or other CI configuration
10. **Last migration**: April 2017 (schema has been stable for years; all migrations run successfully on Heroku)
