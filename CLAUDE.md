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
| Rails | 7.2.3 | Upgraded from 5.1.4; `config.load_defaults 7.2` |
| PostgreSQL | Any modern version | Uses `pg ~> 1.2` gem |
| Redis | — | Required for ActionCable |

**The app runs Rails 7.2.3 on Ruby 3.1.6** with no monkey-patches. All Ruby 3.x
compatibility fixes were eliminated when upgrading from Rails 5.1.4 → 6.1 → 7.2.

## Project Structure

```
app/
  assets/javascripts/    # CoffeeScript + plain JS (Sprockets 3 pipeline)
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
    new_framework_defaults.rb       # Rails 5.0 defaults (all flipped to true)
    new_framework_defaults_7_2.rb   # Rails 7.2 opt-in defaults (all commented out)
    fog_init.rb                     # CarrierWave + fog-aws config (guarded by ENV check)
  application.rb         # config.load_defaults 7.2, autoload_lib, time_zone
  boot.rb                # require 'logger' for Ruby 3.1 compat with Rails 6.x+
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
- **Phrase** — related to words/clues
- **Solution** — a user's solve attempt for a crossword
- **SolutionPartnering** — links users to team solutions
- **CellEdit** — tracks individual cell edits during solving
- **Comment** — threaded comments on crosswords
- **FavoritePuzzle** — user favorites
- **Friendship** — bidirectional friendships (self-join, no primary key)
- **FriendRequest** — pending friend requests (no primary key)

## Rails Upgrade History

The app was upgraded from Rails 5.1.4 → 6.1 → 7.2 in Feb 2026.

### Key changes during upgrade
- All `belongs_to` associations: added `optional: true` to those with nullable FK columns
- `content_tag_for` → `content_tag + dom_id` (removed `record_tag_helper` dependency)
- `render text:` → `render plain:` in 3 controllers
- `include PgSearch` → `include PgSearch::Model` in 3 models (pg_search 2.3.x deprecation)
- `cw.try(:preview)` → `cw.preview_url` in `_crossword_tab.html.haml` (Rails 7 `to_model` change)
- `sass-rails` replaced by `sassc-rails`; `coffee-rails` kept with `sprockets ~> 3.7` pin
- `uglifier` replaced by `terser`

### Deleted files
- `config/initializers/ruby3_compat.rb` — 306 lines of Rails 5.1/Ruby 3.x patches, no longer needed

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

Uses Sprockets 3 pipeline (pinned to `~> 3.7` to keep CoffeeScript support):
- **CoffeeScript** — 12 `.coffee` files (crossword interactions, ActionCable channels, account, global)
- **SASS** via `sassc-rails`
- **jQuery** via `jquery-rails`
- **Turbolinks** (effectively disabled in application.js)
- **Foundation** 5 & 6 (vendored JS/CSS)
- Plain JS files: `solve.js`, `edit.js`

## Testing

- **Framework**: RSpec with `rspec-rails ~> 4.0`
- **Factories**: FactoryBot (renamed from FactoryGirl)
- **Database cleaning**: DatabaseCleaner with truncation strategy (not transactions)
- **Feature tests**: Capybara `~> 3.0` with CSS selectors
- **Coverage**: SimpleCov `~> 0.22`
- **Matchers**: shoulda-matchers `~> 5.0`
- **Custom metadata tags**: `:dirty_inside` (skip DB cleaning), `:skip_callbacks`
- **Transactional fixtures**: disabled

Run tests: `bundle exec rspec`

## Notable Gems and Their Roles

| Gem | Purpose |
|-----|---------|
| `pg ~> 1.2` | PostgreSQL adapter |
| `pg_search` | Full-text search on Crossword, User, Word |
| `active_record_union` | UNION queries in ActiveRecord |
| `carrierwave` + `fog-aws` + `rmagick` | Image uploads to S3 with resizing |
| `pusher` | Real-time push notifications |
| `puma ~> 5.0` + `redis` | ActionCable WebSocket server |
| `bcrypt` | Password hashing |
| `haml ~> 5.2` | View templates |
| `will_paginate ~> 3.0` | Pagination |
| `nilify_blanks` | Convert blank strings to NULL |
| `httparty` | HTTP client (NYT puzzle fetching) |
| `sassc-rails` | SASS/SCSS compilation (replaces sass-rails) |
| `coffee-rails` | CoffeeScript compilation (with sprockets ~> 3.7) |
| `terser` | JS minification in production (replaces uglifier) |

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
- **Status**: Live on Rails 7.2.3 — home, welcome, about, faq, stats, contact, users/new all return 200

Deploy and test workflow:
```bash
git push origin master && git push heroku master
heroku run "bundle exec rails db:migrate 2>&1" --app crosswordcafe
```

## Known Technical Debt

1. **CoffeeScript** — 12 `.coffee` files should be converted to plain JS; blocked on `sprockets ~> 3.7` pin
2. **Sprockets 3 pin** — upgrading to Sprockets 4 requires converting CoffeeScript first
3. **HAML 5.2** — not yet upgraded to HAML 6 (waiting for Sprockets migration)
4. **`remotipart`** — old jQuery UJS gem; compatibility with Rails 7 untested
5. **No CI/CD** — no GitHub Actions, Travis, or other CI configuration
6. **Last DB migration**: April 2017 (schema stable; all migrations run successfully)
7. **Models inherit from `ActiveRecord::Base`** — not updated to `ApplicationRecord` pattern
8. **`new_framework_defaults_7_2.rb`** — all 7.2 defaults commented out; can be enabled/deleted
