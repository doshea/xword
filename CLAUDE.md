# Xword — Crossword Cafe

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

Rails 8.1 web app for solving, creating, and collaborating on crossword puzzles. Features
include team solving (ActionCable), NYT importing, user accounts, comments, and an admin panel.

## Tech Stack Notes

- **Sprockets 4.2** asset pipeline (not importmap or jsbundling); manifest at `app/assets/config/manifest.js`
- **jQuery** still required by `solve_funcs.js` and `edit_funcs.js`
- **Turbo** (Drive + Streams) + **Stimulus** for modern interactions
- All jQuery AJAX calls use `dataType: 'json'` — switched from `dataType: 'script'` because
  `globalEval` silently swallows runtime errors and triggers jQuery's error callback with 200.
  Legacy `.js.erb` templates kept as fallback: `check_cell`, `check_completion`,
  `update_letters`, `live_search`, `solutions/update`
- Global 15s AJAX timeout in `$.ajaxSetup()` prevents hung requests
- `cw.flash(message, type, duration)` for non-blocking inline notifications (replaces `alert()`)

## Project Structure (non-obvious parts)

- `app/controllers/admin/` — all inherit from `Admin::BaseController` (shared CRUD)
- `spec/requests/` — preferred for new HTTP-layer tests; `spec/controllers/` is legacy
- `spec/support/auth_helpers.rb` — `AuthHelpers` (controller) + `RequestAuthHelpers` (request)
- `lib/custom_funcs.rb` — manually required; excluded from Zeitwerk

## Domain Model Notes

- **`Crossword` has no default scope.** Queries that need ordering must add explicit
  `.order(created_at: :desc)` or similar. Controllers for home, profile, NYT, and user-made
  pages already include this. Search relies on pg_search relevance ranking (no explicit order).
- **`Phrase`** — reusable clue text (e.g., "Norse god of wisdom"). A `Clue` is an instance
  of a `Phrase` tied to a `Word` in a specific puzzle. 53K phrases populated, all eligible
  clues linked. Phrases created at publish time via `CrosswordPublisher`.
- Raw SQL bulk inserts in `Crossword#populate_cells` (atomic `INSERT ... RETURNING id`).

## Architecture Direction

Front-end modernization and backend architecture cleanup are both complete. The codebase
is in a healthy, maintainable state. Ongoing principles:

- **Service objects** for multi-step operations: `CrosswordPublisher` (publish pipeline),
  `NytPuzzleImporter` / `NytPuzzleFetcher` / `NytGithubRecorder` (NYT import). Team broadcast
  logic in `SolutionsController` assessed as already clean — not worth extracting.
- **Authorization in models**: `Solution#accessible_by?(user)` replaces 3 controller before_actions.
- **Nil guards at system boundaries**: mirror cell, nytimes user, bare `.find()` calls all guarded.
- **Dead code deleted**: `CellEdit` model, `Newyorkable` concern, unused factories, dead rake tasks.
- **All 6 known runtime risks resolved**: division-by-zero guards, nil mirror cell guard,
  HTTParty 10s timeouts, safe `find_by`/`where` replacing bare `.find()` calls.

## Frontend Hazards

**JS/CSS coupling**: jQuery `.position()` returns coordinates relative to the nearest
positioned ancestor. If CSS refactoring removes `position` from an ancestor, JS scroll/position
math silently breaks. When changing CSS `position` properties, grep for `.position()` and
`.offset()` in JS to check for coupling.

**Comment overlay actions**: Reply/Delete buttons use `opacity: 0` + `pointer-events: none`
at rest, revealed on `:hover` and `:focus-within`. The `:focus-within` selector must be scoped
to `.xw-comment__actions`, NOT the parent `.xw-comment` — otherwise clicking the reply-count
`<button>` (which is a sibling, not inside `__actions`) triggers focus on the comment article
and keeps the overlay visible. See inline CSS comments in `crossword.scss.erb`.

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

Key patterns:
- BEM naming (`xw-comment`, `xw-reply`, `xw-btn`, `xw-alert`); `xw-` prefix for CSS Grid classes
- Ghost buttons (no border) for toolbar actions
- Warm cream `--color-surface-alt` for nested paper-within-paper containers
- `span.clue-num` with `--color-text-muted` for clue numbers

### Responsive Puzzle Layout

The `.xw-puzzle-layout` uses flex (phone/desktop) and CSS Grid (tablet 640-1023px). The tablet
breakpoint uses `grid-template-columns: 1fr 1fr` to keep both clue columns together — flexbox
`wrap` caused one column to wrap alone. Desktop/XL use inline `<style>` from HAML for clue
height based on row count.

## Testing

Run tests: `bundle exec rspec` — ~904 examples, 0 failures

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

### Test Patterns

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

## Technical Debt (Active)

1. **`published` column removed** from Crossword schema; `error_if_published` is a no-op;
   all "published crossword" guards disabled until column is restored. `publish!` deleted
   (was dead code after `CrosswordPublisher` extraction).
