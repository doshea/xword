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
- **jQuery** still required by `solve_funcs.js`, `edit_funcs.js`, and `remotipart`
- **Turbo** (Drive + Streams) + **Stimulus** for modern interactions
- 5 files use `.js.erb` + `format.js` (jQuery AJAX, NOT Turbo Streams):
  `check_cell`, `check_completion`, `solutions/update`, `update_letters`, `live_search`

## Project Structure (non-obvious parts)

- `app/controllers/admin/` — all inherit from `Admin::BaseController` (shared CRUD)
- `spec/requests/` — preferred for new HTTP-layer tests; `spec/controllers/` is legacy
- `spec/support/auth_helpers.rb` — `AuthHelpers` (controller) + `RequestAuthHelpers` (request)
- `lib/custom_funcs.rb` — manually required; excluded from Zeitwerk

## Domain Model Notes

- **`Crossword` default scope**: `order(created_at: :desc)` on all queries. Use `.unscoped`
  or `.reorder` when unwanted.
- **`Phrase`** — reusable clue text (e.g., "Norse god of wisdom"). A `Clue` is an instance
  of a `Phrase` tied to a `Word` in a specific puzzle. FK exists but is unpopulated. Planned
  for clue suggestions during puzzle creation.
- **`CellEdit`** — tracks individual cell edits; unused in current UI. Candidate for removal.
- Raw SQL bulk inserts in `Crossword#populate_cells` (atomic `INSERT ... RETURNING id`).

## Architecture Direction

The front-end modernization is complete. The next phase is **backend architecture cleanup**:

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

Run tests: `bundle exec rspec` — ~693 examples, 0 failures

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
