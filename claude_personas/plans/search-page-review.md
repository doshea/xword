# Search Page — Review

**Page:** `/search` (full search) + `/live_search` (nav bar AJAX)
**Date:** 2026-03-04
**Grade:** B+ — CSS is excellent (fully tokenized, BEM, responsive), live search is well-debounced,
but there are two performance issues (N+1, no result cap) and a missing blank-query guard.

---

## Findings

### 1. N+1: `word.crosswords.size` per word result — **should-fix**

**Severity:** should-fix (performance)
**File:** `app/views/pages/search.html.haml` lines 98-99, `app/controllers/pages_controller.rb` line 91

The controller eager-loads clues (`.includes(:clues)`) but the view also calls `word.crosswords.size`.
`Word#crosswords` is a *custom method* (not a `has_many`), defined as:
```ruby
def crosswords
  Crossword.where(id: across_crosswords.select(:id))
           .or(Crossword.where(id: down_crosswords.select(:id)))
end
```

Each call creates a fresh `ActiveRecord::Relation` — `.includes` cannot help here.
With N word results, this fires **N extra queries** (each with 2 subqueries).

**Fix — Option A (recommended): Precompute counts in controller**

Replace `word.crosswords.size` in the view with a precomputed count hash:

```ruby
# Controller
@words = Word.starts_with(@query).includes(:clues).limit(50).load
@word_crossword_counts = {}
if @words.any?
  # One query: count crosswords per word via the clues→cells→crossword join
  across = Cell.where(across_clue_id: Clue.where(word_id: @words.map(&:id)).select(:id))
               .group('clues.word_id').joins(across_clue: :word).count
  down   = Cell.where(down_clue_id: Clue.where(word_id: @words.map(&:id)).select(:id))
               .group('clues.word_id').joins(down_clue: :word).count
  # ...merge counts
end
```

Actually, the simpler approach: since clues are already eager-loaded and each clue belongs to
cells that belong to crosswords, we can compute the count from the loaded data:

```ruby
# View (no extra queries — uses eager-loaded clues + existing associations):
word.clues.flat_map { |c| [c.across_cells, c.down_cells] }.flatten.map(&:crossword_id).uniq.size
```

But this would still trigger N+1 for cells. **Simplest clean fix:**

```ruby
# Controller — add a crossword_count subquery
@word_crossword_counts = Word.where(id: @words.map(&:id))
  .joins(clues: [:across_cells, :down_cells])  # Nope, this gets complex
```

**Recommended approach:** Use `Word#crosswords` (already efficient as a single SQL query) but
batch the counts. Or: **just display the clue count** (already eager-loaded) and drop the puzzle
count from the word results. The clue count is the more meaningful stat for a search result.

**Builder decision:** Either (A) batch-count crosswords in 1-2 queries via raw SQL, or
(B) remove the puzzle count from word results (simplest, and clue count alone is informative
enough for a search result card). Option B is recommended for simplicity.

---

### 2. No result limit on full search — **should-fix**

**Severity:** should-fix (performance)
**File:** `app/controllers/pages_controller.rb` lines 87-92

Live search correctly limits to 15 results, but full search has **no limit**:
```ruby
@users = User.starts_with(@query).load                                    # no limit
@crosswords = Crossword.starts_with(@query).includes(:user).load          # no limit
@words = Word.starts_with(@query).includes(:clues).load                   # no limit
```

A broad query like "a" could return hundreds of crosswords, dozens of users, and thousands of
words. The view renders all of them inline (no pagination). This could cause:
- Slow page load (large HTML payload)
- High memory usage
- Combined with the N+1 above, potentially hundreds of queries

**Fix:** Add `.limit(50)` to all three queries. 50 matches `per_page` on most models.
If desired later, add will_paginate per-section pagination.

```ruby
def search
  @query = params[:query]
  return if @query.blank?
  @users = User.starts_with(@query).limit(50).load
  @crosswords = Crossword.starts_with(@query).includes(:user).limit(50).load
  @words = Word.starts_with(@query).includes(:clues).limit(50).load
end
```

---

### 3. Blank query fires 3 unnecessary DB queries — **should-fix**

**Severity:** should-fix (correctness + performance)
**File:** `app/controllers/pages_controller.rb` lines 87-92

When visiting `/search` with no query param, `@query` is nil. The controller still calls
`User.starts_with(nil)`, `Crossword.starts_with(nil)`, and `Word.starts_with(nil)`.

pg_search currently handles nil gracefully (returns empty results), but this fires 3 pointless
queries. The view already has `if @query.present?` guards that skip result rendering.

**Fix:** Short-circuit the controller:

```ruby
def search
  @query = params[:query]
  return if @query.blank?
  @users = User.starts_with(@query).limit(50).load
  @crosswords = Crossword.starts_with(@query).includes(:user).limit(50).load
  @words = Word.starts_with(@query).includes(:clues).limit(50).load
end
```

View must then handle nil collections (e.g., `@crosswords&.any?` or `@crosswords.present?`).
Or initialize to empty arrays: `@users = @crosswords = @words = []`.

---

### 4. Live search dropdown lacks keyboard navigation — **suggestion**

**Severity:** suggestion (a11y)
**File:** `app/assets/javascripts/global.js` lines 32-58

The live search dropdown appears on keyup, but:
- No arrow-key navigation to move through results
- No Escape key to dismiss
- No `role="listbox"` or `aria-activedescendant` on the results container
- No `aria-expanded` on the search input
- The `#live-results` div has no ARIA live region

The search hero on the full page correctly uses `role="status"` and `aria-live: "polite"` for
the summary stats — this is well done.

**Fix:** This is a larger change (enhanced dropdown a11y). Consider:
1. Add `role="listbox"` to `#live-results`, `role="option"` to each `<li>`
2. Add arrow-key navigation in the `live_search` handler
3. Add Escape to dismiss
4. Add `aria-expanded` and `aria-controls` to `#query` input

**Scope note:** This could be a standalone a11y ticket if it's too large for this batch.

---

### 5. Live search inconsistency: crosswords lacks `.includes(:user)` — **nitpick**

**Severity:** nitpick (defensive)
**File:** `app/controllers/pages_controller.rb` line 100

```ruby
@crosswords = Crossword.starts_with(query).limit(max_results).load  # no .includes(:user)
```

The `_live_results` partial only accesses `crossword.title` (no user access), so this is
currently safe. But the full search includes `:user` defensively. Adding it here would prevent
a future N+1 if the partial is ever modified to show bylines.

---

### 6. `should` syntax in controller specs — **nitpick**

**Severity:** nitpick (test quality)
**File:** `spec/controllers/pages_controller_spec.rb`

The existing controller spec for `live_search` and `search` uses `it { should respond_with(:success) }`.
Per CLAUDE.md, `expect()` syntax only. These should migrate when touched.

---

### 7. No request spec coverage for live_search — **nitpick**

**Severity:** nitpick (test coverage)
**File:** `spec/requests/pages_spec.rb`

Full search has 4 request specs (good). Live search only has controller specs (legacy).
A request spec for live_search (JSON format, result splitting, blank query) would be valuable.

---

## What's Already Good

- **CSS is excellent.** `search.scss.erb` is 456 lines, fully tokenized, BEM-named
  (`.xw-search-hero`, `.xw-search-card`, `.xw-search-puzzle`, `.xw-search-user`,
  `.xw-search-word`). Responsive breakpoint works well. Hover/focus states present.
  Paper texture hero, subordinate result cards. Matches the site's editorial warmth.

- **Live search debouncing.** 300ms debounce, min 3 chars, proper timeout cleanup. Good.

- **Search result splitting.** Live search splits max_results evenly across non-empty categories.
  Clever algorithm that prevents one type from crowding others.

- **Crossword results eager-load `:user`.** No N+1 on user access in the crossword section.

- **Clue eager-loading.** `word.clues.size` uses the preloaded collection — efficient.

- **Empty state treatment.** Empty results show tips as pill badges. Clean.

- **`aria-live` on search stats.** The summary badges have `role="status"` + `aria-live: "polite"`.

---

## Recommended Implementation Order

1. **Blank query guard** (finding #3) — trivial, prevents 3 wasted queries
2. **Result limit** (finding #2) — one-line `.limit(50)` per query
3. **N+1 fix** (finding #1) — either remove puzzle count from word cards or batch-count
4. **Keyboard a11y** (finding #4) — larger scope, could be separate ticket
5. **Test cleanup** (findings #6, #7) — while touching the file

Files to change:
- `app/controllers/pages_controller.rb` (#search action)
- `app/views/pages/search.html.haml` (nil-safe collection checks, possibly remove puzzle count)
- `spec/requests/pages_spec.rb` (add live_search request specs)
- `spec/controllers/pages_controller_spec.rb` (`should` → `expect`)
