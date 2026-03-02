# Xword - Crossword Puzzle Application

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
- Keep models to validations, associations, scopes, and callbacks. Keep controllers to request handling. If business logic is needed somewhere, ask where it should go.

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

## Project Structure

```
app/
  assets/javascripts/    # Plain JS (converted from CoffeeScript Feb 2026)
  channels/              # ActionCable channels (messages_channel.rb, teams_channel.rb)
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
  controllers/           # 10 controller specs + admin/
  mailers/               # 2 mailer specs (UserMailer, AdminMailer)
  models/                # 9 model specs
  features/              # 2 integration specs (login, solve)
  factories/             # FactoryBot factories
vendor/
  assets/                # Foundation 5 & 6 JS only (CSS removed in Phase 6)
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

### Key changes during upgrade (Feb 2026)
- API migrations: `belongs_to` → `optional: true`; `render text:` → `render plain:`; `include PgSearch::Model`
- CoffeeScript → plain JS (12 files); `sass-rails` → `sassc-rails`; `uglifier` → `terser`
- All 14 models → `ApplicationRecord`; CarrierWave `extension_allowlist`; factories use block syntax
- `Procfile` added; GitHub Actions CI added (Postgres 16, rspec)
- **Hotwire migration**: `turbolinks` + `jquery_ujs` → `turbo-rails` + `stimulus-rails`
  - 13 `.js.erb` → `.turbo_stream.erb`; `remote: true` → `form_with`; 5 `.js.erb` kept (jQuery AJAX)
- **Phase 2**: Foundation Icons → inline Lucide SVGs (`icon()` helper, 34 SVGs)
- **Phase 3**: Foundation grid → `xw-` CSS Grid (35 HAML files)

### Changes (Mar 2026)
- **Race conditions**: `populate_cells` atomic `INSERT … RETURNING id`; team key unique index + retry
- **20 FK indexes** added; **signed auth cookies** (`cookies.signed[:auth_token]`)
- **Test suite**: all controller + model behavior specs (9 main + 6 admin controllers)
- **Solutions/null bug**: 3-layer fix (`.to_json` in HAML, JS guard, `guard_null_solution_id` before_action)
- **Partial audit**: `_crossword_tab.html.haml` `cw:` mismatch fixed in 3 callers; 2 orphaned partials deleted
- **Pusher → ActionCable**: 6 team events migrated; `pusher` gem removed; `TeamsChannel` added
- **ActionMailer cleanup**: dead methods/actions removed; `AdminController#test_emails` added
- **Cuprite**: JS integration tests; IIFEs in turbo/stimulus sprockets to prevent variable collisions
- **Design audit**: dead FB/GA removed; Google Fonts loaded; focus rings fixed; heading hierarchy; content rewrites

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
- **Foundation** 5 & 6 (vendored JS only; CSS removed in Phase 6)
- Manifests: `application.js`, `solve.js`, `edit.js`
- **NOTE**: Files calling `$.ajax({ dataType: 'script' })` use `.js.erb` + `format.js` (NOT Turbo Streams):
  `check_cell.js.erb`, `check_completion.js.erb`, `solutions/update.js.erb`,
  `update_letters.js.erb`, `live_search.js.erb`
- **JS/CSS coupling hazard**: jQuery `.position()` returns coordinates relative to the nearest
  positioned ancestor (`position: relative/absolute/fixed`). If CSS refactoring removes `position`
  from an ancestor, JS scroll/position math silently breaks. When changing CSS `position` properties,
  grep for `.position()` and `.offset()` in JS to check for coupling. Learned from: `.clues` container
  lacked `position: relative`, causing `scroll_to_selected()` to scroll clues out of view.

## Visual Design

**When asked about style, aesthetics, or visual design of this app, always use the `frontend-design` skill
for assessment and recommendations before proposing changes.**

### Design Philosophy

Cozy "paper on wood" — a crossword worksheet sitting on a café table. The aesthetic is editorial
warmth, not sterile web app. Key colors: **black, white, forest green, warm wood tones**. The
existing palette (warm near-blacks, cream surfaces, tan borders, green accents) is intentional
and should be refined, not replaced.

Typography: Playfair Display (editorial serif headings), Lora (readable serif body/clues),
DM Sans (clean sans for UI chrome), Courier Prime (monospace for cells).

### Design History (Feb-Mar 2026)

| Phase | What changed |
|-------|-------------|
| Phase 0 | Design tokens (`_design_tokens.scss`), CSS Grid (`_grid.scss`), components (`_components.scss`) |
| Phase 1 | Foundation `.top-bar` → `.xw-nav` with Stimulus nav/dropdown controllers |
| Phase 2 | Foundation Icons (`fi-*`) → inline Lucide SVGs via `icon()` helper (34 SVGs) |
| Phase 3 | Foundation 5 grid → `xw-` CSS Grid classes (35 HAML files migrated) |
| Phase 4a | Semantic HTML + accessibility: landmarks, heading hierarchy, ARIA labels |
| Phase 4b | Foundation JS removal: reveal-modals → native `<dialog>`, tabs/dropdowns → Stimulus |
| Phase 5 | Visual modernization: `.alert-box`→`.xw-alert`, `.button`→`.xw-btn`, pagination, dead CSS removed |
| Phase 6 | Foundation CSS vendor bundle deleted (~1.4MB); minimal CSS reset added to `global.scss.erb` |
| Design audit | Google Fonts loaded, focus rings fixed, footer tokenized, heading hierarchy, content rewrites |
| CSS cleanup | Vendor prefixes removed, dead mixins deleted, crossword colors tokenized |
| Edit page polish (v1-v7) | Paper shadow + rounded corners on crossword sections, title input refined, clue textareas auto-size, clue row breathing room, description textarea sunken background |
| Edit page polish (v8) | Switch colors calmed (red→warm gray off, lime→forest green on), clue numbers muted, clue containers warmed to cream, section divider strengthened, bottom padding tightened, clue column border-left removed, textarea border softened, clue scroll-into-view bug fixed |
| Solve page polish (v8.2) | Clue numbers wrapped in `span.clue-num` (shared muted color), `<hr>` dividers styled with warm borders, `#solve-controls` modernized from float to flow, `#puzzle-controls` absolute→flex, comment textarea sunken bg, Comments heading display font |
| v9-v10 | Ghost toolbar buttons, creator credit byline, comments BEM layout, Turbo Stream fixes, `populate_cells` bug fix |
| v11-v12 | Modal polish (controls keycaps, win modal tokens), edit tool panels tokenized, settings modal cleaned |
| v13-v17 | Inline styles → CSS classes site-wide, legacy shadow classes removed, search cards tokenized, profile page polished, team chat/grid/nav colors tokenized |
| v18 | Legacy cleanup: `.dark-shadow` removed (nav + edit), `.lead`/`.subheader` dead CSS deleted, `.subheader`→`.xw-footer__copyright`, home `<hr>` inline style→`.xw-hr--flush` |
| v19 | Accessibility & semantic HTML audit: heading hierarchy fixed site-wide, valid list nesting, `<main>` landmark, `aria-labelledby`, `<time>` elements, `.form-error-summary` class |
| v20 | Admin inline styles→CSS classes: `.xw-textarea--uppercase`, `.xw-admin-cell--compact`, `.xw-admin-highlight`; table width:100% removed |
| v21 | Mobile responsiveness: phone breakpoints for team chat (full-width), comments (reduced indent), controls modal (single column), tabs (horizontal scroll), edit tool panels (full-width); XL breakpoints for container + cells |

### Current State (v21) — What's Working

- Paper-on-wood metaphor reads immediately; wood grain bg + cream paper card + `--shadow-paper` depth
- Crossword grid is crisp: strong black/white contrast, clean cell borders
- Typography pairing (Playfair headings / DM Sans labels / Lora body) creates editorial hierarchy
- Green accent coherent: Publish button, switch on-state, Check button, `--color-accent` all `#3a7d5c`
- Toggle switches recede (warm gray off-state) instead of competing with content
- Clue containers use warm cream (`--color-surface-alt`) — paper-within-paper feel
- Clue numbers muted on both pages via shared `.clue-num { color: var(--color-text-muted) }`
- Continuous paper texture across `#credit-area` → `#solve-area` → `#meta-area` → `#advanced`
- Section dividers visible and consistent: warm `--color-border` on solve, `--color-border-strong` on edit
- Puzzle controls flex-positioned with ghost buttons (no border noise), status text muted
- Creator credit byline styled with `--font-body` + `--color-text-secondary` (editorial feel)
- Comment textarea sunken with `.xw-textarea` class, Comments heading uses `--font-display`
- Comments/replies use BEM flex layout (`xw-comment`/`xw-reply` with `__avatar`/`__body` children)
- All inline `style` attributes removed from comment/reply/modal partials — display states in CSS
- Controls modal: keycap styling with `--font-mono`, border+shadow, proper heading hierarchy
- Win modal: BEM classes, tokenized clock styling, `.xw-textarea` on comment input
- Edit page: tool panels use `--color-nav-bg/text/border`, cross-browser scrollbar, settings modal cleaned
- Search/home page: crossword cards use `--color-border` solid border, `--color-surface-alt` hover,
  token-based spacing and typography
- Profile page: heading hierarchy fixed, CSS tokenized, dead `.right` class removed
- Nearly all hardcoded colors in CSS files replaced with design tokens
- Semantic HTML: proper heading hierarchy, `<main>` landmark, `aria-labelledby` on sections
- Mobile responsive: phone breakpoints stack layout, scroll tabs, full-width panels
- XL screens (1280px+): wider container, larger cells, taller clue columns
- Admin views: all inline styles replaced with CSS utility classes

### Completed Versions

| Version | What changed |
|---------|-------------|
| v8.2 | Clue numbers wrapped in `span.clue-num`, `<hr>` warm borders, `#solve-controls` flow layout, `#puzzle-controls` absolute→flex, comment textarea + heading styling |
| v9 | Ghost toolbar buttons, status text muted `--font-ui`/`--text-xs`, orphaned `%br` removed, creator credit byline `--font-body`/`--color-text-secondary` |
| v10 | Comments BEM layout (`xw-comment`/`xw-reply`), inline styles→CSS, reply count `h6`→`p`, Turbo Stream wrapper fix, `populate_cells` `cells.reset` bug fix |
| v11 | Controls modal keycaps (`kbd` styling), win modal inline styles→BEM classes, both modals h1→h2, `<u>` tag removed |
| v12 | Edit page tool panels tokenized (`$bottomcolor`→`--color-nav-bg`, etc.), settings modal cleaned (bare checkboxes→placeholder), cross-browser scrollbar, `.potential-word__row` class |
| v13 | Inline styles→CSS classes: favorited star→`.xw-icon--favorited`, creator avatar→`.xw-thumbnail`, login icon→`.xw-icon--accent`, admin flag→`.xw-icon--danger`. Dead `.small-shadow`/`.shadow`/`.thin-border`/`.light-shadow` removed from global CSS |
| v14 | Login page inline flex styles→`.xw-auth-layout`/`.xw-auth-column` CSS; error page image→`.xw-error-image`; dead `.text-center`→`.center` |
| v15 | Search cards tokenized: `lightgrey`→`--color-border`/`--color-surface-alt`, dotted→solid border, `--radius-sm`, token spacing/typography. Solution choice: `#f04124`→`--color-danger`, blue overlay→muted info tint |
| v16 | User profile: `h5`→`h3` Stats heading, dead `.right` class removed, leading `%br` removed, `profile.scss.erb` tokenized, `account.scss.erb` `#333`→`--color-text` |
| v17 | Tokenized: grid `tr` bg→`--color-cell-void`, clue border `#999`→`--color-border-strong`, team chat black/white→nav tokens + `--shadow-lg` + `--radius-md`, bookend bars→nav tokens, nav danger `#f77`→`--color-danger`, new_crossword preview→cell tokens |
| v18 | Legacy cleanup: `.dark-shadow` deleted (nav header + edit settings→`var(--shadow-lg)`), dead `.lead`/`.subheader` CSS removed, `.subheader`→`.xw-footer__copyright` (inlined props), home `<hr>` inline style→`.xw-hr--flush` class |
| v19 | Accessibility: heading hierarchy (h3→h1, h5→h2/h4/p, h6→p across 19 views), valid `<ul>/<li>` nesting in home tabs + batch stream, `<main>` landmark, `aria-labelledby` on login sections, `<time datetime>` on profile, `.form-error-summary`/`.search-result-count` classes, `<u>` tags removed |
| v20 | Admin inline styles: `style='width:100%'`→removed, `lightgreen`→`.xw-admin-highlight`, `text-transform:uppercase`→`.xw-textarea--uppercase`, `font-size:6px`→`.xw-admin-cell--compact` (7 inline attrs across 5 files) |
| v21 | Mobile: phone (<640px) team chat full-width, comments full-width replies + reduced indent, controls modal single-column, tabs horizontal scroll, edit tool panels full-width. XL (1280px+) wider container + padding, larger cells, taller clues, wider team chat |

### Remaining Cleanup

#### Ongoing
1. **Mobile tablet range (768-1024px)** — phone and desktop breakpoints are in place; tablet-specific
   refinements (e.g., 2-column clue layout on iPad) could improve the intermediate range.
2. **Legacy utility class `.center`** — 14 uses, simple `text-align: center` utility with no hardcoded
   colors. Harmless and widely used; renaming would touch 14+ files for zero functional benefit.
3. **Email template** — `default_mail.html.haml` uses inline styles (correct for email; leave as-is).
4. **Admin visual polish** — inline styles replaced (v20), but admin pages could benefit from further
   design treatment (low priority).

### Pages Not Yet Polished

Primary pages (solve + edit) are polished. Secondary pages partially addressed:
- Home page / search results — crossword cards tokenized (v15), tabs styled
- Login / signup — flex layout tokenized (v14), heading fixed
- User profile — heading hierarchy + CSS tokenized (v16)
- About / FAQ / Contact — content rewritten (design audit), could benefit from further visual treatment
- Admin panel — functional, low priority

## Testing

- **Framework**: RSpec with `rspec-rails ~> 8.0` (8.0.3)
- **Factories**: FactoryBot 6.5 (all attributes use block syntax)
- **Database cleaning**: DatabaseCleaner 2.1 — transactions for unit specs, truncation for `js: true` feature specs
- **Feature tests**: Capybara `~> 3.0`; rack-test driver for non-JS specs; Cuprite (headless Chrome via CDP) for JS-capable specs (`js: true`)
- **Coverage**: SimpleCov `~> 0.22`
- **Matchers**: shoulda-matchers `~> 7.0`
- **Controller specs**: require `rails-controller-testing` (installed)
- **Shared helpers**: `spec/support/auth_helpers.rb` — `log_in(user)` for controller specs

Run tests: `bundle exec rspec`  # ~570 examples, 0 failures

### Test-Writing Guidelines

**Use `expect()` syntax only.** The `should` syntax is deprecated. Do not use `subject.stub(...)` —
use `allow(subject).to receive(...)`. Do not use `rspec-its` `its(:method)` — write explicit `it` blocks.

**Test behavior, not markup.** View specs should assert:
- Semantic HTML (correct element types: `article` not `div`, `h1` not `h3`)
- Accessibility attributes (ARIA labels, `aria-labelledby`, heading hierarchy)
- Absence of anti-patterns (inline `style` attributes during migration)

View specs should NOT assert CSS class names, specific nesting depth, or DOM structure that's
purely presentational. If the class name changes but the page still works, the test shouldn't break.

**No empty placeholder specs.** Don't scaffold out empty `context`/`describe` blocks for sections
you haven't written yet. They create false confidence and noise in `--format documentation` output.

**Don't test broken state as expected behavior.** If an action raises `MissingExactTemplate`, fix
the action or remove it — don't write a spec asserting the error.

**New specs should be request specs** (`type: :request`), not controller specs. Controller specs
(`type: :controller`) are legacy. Existing controller specs don't need to be rewritten, but all
new HTTP-layer specs should use `get '/path'` style, not `get :action, params:`.

**Model specs should test business logic.** Validations and associations are a baseline, but the
real value is testing methods that compute, transform, or make decisions. Test return values with
concrete inputs, not just return type/shape.

**Factories should be used or deleted.** If a record is always sourced from an association
(cells from crossword), a standalone factory is dead code.

## Notable Gems and Their Roles

| Gem | Version | Purpose |
|-----|---------|---------|
| `pg` | 1.6.3 | PostgreSQL adapter |
| `pg_search` | 2.3.7 | Full-text search on Crossword, User, Word |
| `active_record_union` | 1.3.0 | UNION queries in ActiveRecord |
| `carrierwave` | 3.1.2 | Image uploads to S3 |
| `fog-aws` | 3.33.1 | AWS S3 backend for CarrierWave |
| `rmagick` | 5.5.0 | Image resizing |
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
| `cuprite` | — | Headless Chrome driver for Capybara JS feature specs |

## Key Commands

```bash
bundle install          # Install dependencies
rails db:create         # Create dev + test databases
rails db:migrate        # Run migrations
rails server            # Start dev server (Puma)
bundle exec rspec       # Run test suite (~510 examples, 0 failures)
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
6. **Ruby 3.5** — only preview1 available as of Feb 2026; upgrade when stable
