# Test Suite Health Audit

**Job 15 from meta-plan. Reviewed 2026-03-04.**

---

## Summary

| Category | Findings |
|----------|----------|
| Controller→request migration | 8 controller specs with no request counterpart; 10 with heavy duplication |
| `should` → `expect()` syntax | **147 occurrences** across 20 files |
| Flaky `live_search` test | Root cause identified — `let_it_be` + pg_search interaction |
| Feature spec gaps | 6 feature specs exist; ~18 user-facing flows lack browser coverage |

---

## 1. Flaky `live_search` Test — must-fix

**File:** `spec/controllers/pages_controller_spec.rb:30`
**Symptom:** "html empty for word-only match" — intermittent, order-dependent

### Root Cause

The test uses `let_it_be` to create a User (username: 'puzzlemaker'), Crossword, and
Word (content: 'PUZZLE'), then searches for 'puzzle' via `pg_search`'s `starts_with`
scope (PostgreSQL `tsearch` with `prefix: true`).

`let_it_be` creates data once in `before(:all)` and relies on test_prof's `before_all`
adapter to manage cleanup. With `use_transactional_fixtures = false` and DatabaseCleaner
managing transactions, the data visibility to `pg_search`'s full-text search queries
becomes order-dependent. When the test suite runs with certain random seeds, the
pg_search FTS query fails to find the `let_it_be` records, returning 0 results
and omitting the `html` key from the JSON response.

The test passes 100% of the time in isolation (verified 10 consecutive runs). The
flakiness only manifests during full-suite runs with specific random orderings.

### Fix

**Option A (recommended):** Replace `let_it_be` with `let!` for this context only.
Creates fresh data inside each test's DatabaseCleaner transaction, ensuring pg_search
always has visible data:

```ruby
context 'with JSON format (current client)' do
  let!(:search_user) { create(:user, username: 'puzzlemaker') }
  let!(:crossword)   { create(:crossword) }
  let!(:word)        { Word.create!(content: 'PUZZLE') }
  # ... tests unchanged
end
```

**Option B:** Stub `starts_with` to return known records, avoiding pg_search entirely
in this controller spec. More reliable but doesn't test the actual search integration.

**Recommendation:** Option A. The performance cost is negligible (3 records per test ×
3 tests = 9 creates, ~100ms).

---

## 2. `should` → `expect()` Syntax Migration — should-fix

**147 occurrences across 20 files.** The spec_helper already configures `ec.syntax = :expect`,
but `shoulda-matchers` provides its own `should` via one-liner syntax (`it { should ... }`).

### Scope

**Model specs (87 occurrences, 11 files):**
- `user_spec.rb` — 35 (biggest file: validations + associations)
- `crossword_spec.rb` — 19
- `comment_spec.rb` — 6
- `cell_spec.rb` — 6
- `phrase_spec.rb` — 8
- `solution_spec.rb` — 4
- `solution_partnering_spec.rb` — 3
- `friendship_spec.rb` — 2
- `friend_request_spec.rb` — 2
- `favorite_puzzle_spec.rb` — 2

**Controller specs (56 occurrences, 9 files):**
- `users_controller_spec.rb` — 17
- `admin_controller_spec.rb` — 8
- `crosswords_controller_spec.rb` — 7
- `unpublished_crosswords_controller_spec.rb` — 6
- `sessions_controller_spec.rb` — 5
- `pages_controller_spec.rb` — 5
- `solutions_controller_spec.rb` — 4
- `clues_controller_spec.rb` — 2
- `cells_controller_spec.rb` — 2

**Shared examples (4 occurrences, 1 file):**
- `spec/support/shared_examples/admin_crud.rb` — 4

### Transformation

```ruby
# Before
it { should respond_with(:success) }
it { should validate_presence_of(:content) }
it { should belong_to(:user) }

# After
it { is_expected.to respond_with(:success) }
it { is_expected.to validate_presence_of(:content) }
it { is_expected.to belong_to(:user) }
```

Purely mechanical find-and-replace:
- `{ should ` → `{ is_expected.to `
- `{should ` → `{ is_expected.to `
- `{ should_not ` → `{ is_expected.not_to `
- `{should_not ` → `{ is_expected.not_to `

### Priority

**should-fix.** The code works today (shoulda-matchers supports both syntaxes), but
it conflicts with the project's own `ec.syntax = :expect` configuration and CLAUDE.md's
"expect() only" rule. Mechanical change, zero risk.

---

## 3. Controller → Request Spec Migration — suggestion (long-term)

### Current State

- **18 controller spec files** (1,496 lines)
- **19 request spec files** (3,507 lines)
- CLAUDE.md says: "New HTTP specs must be request specs"

### Analysis

**Heavy duplication (6 pairs — consolidation candidates):**

| Controller | Request | Overlap |
|------------|---------|---------|
| sessions | sessions | ~95% duplicate; request adds open-redirect prevention |
| pages | pages | ~80% duplicate; request is far more thorough |
| comments | comments | ~70% duplicate; request adds notifications |
| create | create | ~90% duplicate; request adds ordering/empty-state |
| users | users | ~80% duplicate; request adds account deletion |
| cells | cells | ~60% duplicate; request adds cascade behavior |

**Complementary (4 pairs — keep both):**

| Controller | Request | Reason |
|------------|---------|--------|
| crosswords | crosswords | Controller: favorites; Request: solution repair, XSS |
| solutions | solutions | Controller: Redis error handling; Request: interleaved edits |
| unpublished_crosswords | unpublished_crosswords | Controller: potential_words; Request: publish flow |
| clues | clues | Controller: #show; Request: admin authorization |

**No request spec counterpart (8 controller specs — gaps):**

| Controller Spec | Lines | Notes |
|----------------|-------|-------|
| `admin_controller_spec.rb` | ~90 | Main admin routes: email, clone, manual_nyt |
| `admin/clues_controller_spec.rb` | ~20 | Shared CRUD |
| `admin/comments_controller_spec.rb` | ~25 | Shared CRUD + nil user |
| `admin/crosswords_controller_spec.rb` | ~20 | Shared CRUD |
| `admin/solutions_controller_spec.rb` | ~25 | Shared CRUD + nil edges |
| `admin/users_controller_spec.rb` | ~20 | Shared CRUD |
| `admin/words_controller_spec.rb` | ~20 | Shared CRUD |
| `words_controller_spec.rb` | ~30 | #show + #match |

### Recommendation

**Don't bulk-migrate.** The duplicated controller specs work and provide value. Instead:

1. **When modifying a controller**, migrate its controller spec to request spec at that time
2. **Priority targets** for proactive migration (most duplicate, least unique value):
   - `sessions_controller_spec.rb` — 95% covered by request spec
   - `pages_controller_spec.rb` — only unique value is live_search (which is flaky)
   - `create_controller_spec.rb` — 90% covered by request spec
3. **Admin specs** — low priority (owner-only, shared CRUD provides baseline coverage)
4. **Words controller** — add request spec when words page is next touched

---

## 4. Feature Spec Coverage — suggestion

### Current Coverage (6 feature specs)

| Feature Spec | What it Tests |
|-------------|--------------|
| `accessibility_spec.rb` | Landmarks, headings, ARIA on home + login + crossword |
| `admin_spec.rb` | Admin nav, users list, pagination |
| `edit_spec.rb` | Notepad, pattern search, potential words, Turbo nav |
| `home_tabs_spec.rb` | Tab switching (New/In Progress/Solved) |
| `login_spec.rb` | Login form, error messages, forgot password link |
| `solve_spec.rb` | Cell selection, highlighting, direction toggle, clue nav |

### Notable Gaps

**High-value gaps** (complex JS interactions, no feature spec):
1. **Team solving** — ActionCable collaboration, chat, real-time cell updates
2. **Comments** — threading, reply/delete UI, notification triggers
3. **Search** — live search dropdown, result rendering, keyboard nav

**Medium-value gaps** (simpler flows, well-covered by request specs):
4. Signup flow
5. Password reset (forgot → email → reset form)
6. Profile editing
7. Notifications dropdown
8. Favorites toggle
9. Puzzle creation form

### Recommendation

**Don't pursue exhaustive feature spec coverage.** The current strategy is sound:
- Feature specs for JS-heavy interactive flows (solve, edit)
- Request specs for HTTP correctness (comprehensive — 3,507 lines)
- Accessibility feature spec for structural compliance

**If adding feature specs, prioritize:**
1. **Team solving** — ActionCable is untestable at the request level; this is the biggest
   behavioral gap. High complexity to write, but highest value.
2. **Live search dropdown** — JS-dependent flow with no reliable test (the controller spec is flaky)

---

## 5. Other Observations — nitpick

### Spec count discrepancy
MEMORY.md says "~761 examples" but CLAUDE.md says "~904 examples". The test suite has
grown. Update MEMORY.md to reflect the current count after the next full run.

### `dirty_inside` metadata
Only used in `crossword_spec.rb` for `#populate_cells` (raw SQL bulk inserts). This
bypasses DatabaseCleaner's normal transaction strategy. It works correctly but is
unusual — worth a comment explaining why it exists if one isn't already present.

### SimpleCov configuration
`SimpleCov.start 'rails'` runs on every spec execution, including single-file runs.
The 14.1% coverage reported on single-file runs is noise. Not a bug, just noisy output.

---

## Builder Handoff

### Batch 1 (quick wins)
1. **Fix flaky test** — replace `let_it_be` with `let!` in pages_controller_spec.rb lines 26-28
2. **Migrate `should` → `is_expected.to`** — mechanical find-replace across 20 files (147 occurrences)

### Batch 2 (when touching these files)
3. Delete `sessions_controller_spec.rb` (fully superseded by request spec + open-redirect tests)
4. Delete `create_controller_spec.rb` (fully superseded by request spec)
5. Migrate `pages_controller_spec.rb` unique tests (live_search) to request spec, then delete

### Not recommended now
- Bulk controller→request migration
- New feature specs for medium-value gaps
- Admin request specs (low traffic, owner-only, shared CRUD covers basics)
