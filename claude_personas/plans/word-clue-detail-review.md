# Word & Clue Detail Pages — Review

**Date:** 2026-03-04
**Grade:** C+ (functional but bare-bones — no page title, N+1, missing context for users)
**Pages:** `/words/:id`, `/clues/:id`
**Files:** `words/show.html.haml`, `words/partials/_word.html.haml`, `clues/show.html.haml`,
`words_controller.rb`, `clues_controller.rb`, `word.rb`, `clue.rb`

---

## What's Good

- `.xw-prose` wrapper gives clean editorial typography (Playfair h1/h2, Lora body, green accent)
- `topper_stopper` layout provides consistent page chrome (dark bookend bars)
- `_crossword_tab` partial renders polished puzzle cards
- `find_object` has proper `RecordNotFound` rescue (redirects with flash)
- Clue show has orphan guard — redirects to error if clue has no crosswords
- Clue update has correct authorization (owner or admin; `head :forbidden` for others)
- `Word.word_match` has timeout + rescue for external API
- Controller spec and request spec coverage is solid for auth paths

---

## Findings

### 1. N+1 on `crossword.user` in puzzle lists — **should-fix**
**Severity:** should-fix (performance)
**Location:** `WordsController#show`, `CluesController#show`, `Word#crosswords_by_title`, `Clue#crosswords_by_title`

`crosswords_by_title` returns a relation without `.includes(:user)`. The `_crossword_tab`
partial accesses `cw.user`, `cw.user.deleted?`, `cw.user.display_name`, `cw.user.username` —
one extra query per crossword.

**Fix:** Add `.includes(:user)` to `crosswords_by_title` in both `Word` and `Clue` models.
Also add to `Phrase#crosswords_by_title` for consistency.

```ruby
# word.rb
def crosswords_by_title
  crosswords.includes(:user).order(:title)
end

# clue.rb
def crosswords_by_title
  Crossword.where(id: across_crosswords.select(:id))
           .or(Crossword.where(id: down_crosswords.select(:id)))
           .includes(:user)
           .order(:title)
end

# phrase.rb — same pattern
def crosswords_by_title
  crosswords.includes(:user).order(:title)
end
```

### 2. Missing `<title>` tag — **should-fix**
**Severity:** should-fix (SEO + usability)
**Location:** `words/show.html.haml`, `clues/show.html.haml`

Every other page in the app calls `title()`. These two pages default to bare "Crossword Café".

**Fix:**
```haml
-# words/show.html.haml — add line 1:
- title "#{@word.content} — Word"

-# clues/show.html.haml — add line 1:
- title truncate(@clue.content, length: 50)
```

### 3. Ruby sort instead of SQL order — **should-fix**
**Severity:** should-fix (performance)
**Location:** `WordsController#show` line 8

`@clues = @word.clues.sort_by(&:difficulty)` loads all clues into Ruby arrays, then sorts
in memory. Should use SQL ordering.

**Fix:**
```ruby
@clues = @word.clues.order(:difficulty)
```

### 4. Clue page doesn't show its associated word — **suggestion**
**Severity:** suggestion (UX completeness)
**Location:** `clues/show.html.haml`

The clue page shows the clue text and the puzzles it appears in, but never mentions the
word it's a clue *for*. Users arriving at this page (from search, word page, or direct link)
have no context about which answer this clue maps to.

**Fix:** Add the word link below the h1:
```haml
%h1= @clue.content
- if @clue.word
  %p.xw-prose__subtitle
    Clue for
    = link_to @clue.word.content, @clue.word
    %span (#{@clue.word.content.length} letters)
```

Note: `@clue.word` is a belongs_to, already loaded — no extra query.

### 5. Word page missing word length — **suggestion**
**Severity:** suggestion (UX)
**Location:** `words/partials/_word.html.haml`

The word partial just renders an h1 with the word content. For a crossword dictionary page,
the word's letter count is core information.

**Fix:** Add length below the h1 or as a subtitle:
```haml
%h1= @word.content
%p.xw-prose__subtitle #{@word.content.length} letters
```

### 6. Clue list has no difficulty indicator — **suggestion**
**Severity:** suggestion (UX)
**Location:** `words/show.html.haml` clues section

The clues are sorted by difficulty (1-5) but the difficulty level isn't shown. Users see
a flat list of links with no way to understand the ordering.

**Fix:** Show difficulty as a visual indicator (stars, dots, or number):
```haml
%ul
  - @clues.each do |clue|
    %li
      %span.xw-difficulty= '●' * clue.difficulty + '○' * (5 - clue.difficulty)
      = link_to clue.content, clue
```

Or simply append a parenthetical: `(difficulty: 3/5)`.

### 7. No pagination on crossword or clue lists — **nitpick**
**Severity:** nitpick (acceptable for now)

Both pages load all crosswords and clues at once. In practice, most words appear in <20
puzzles and have <10 clues, so this is acceptable. If a common word (e.g., "THE") has 100+
entries, it could be slow. `per_page = 50` is defined on both models but not used here.

**Recommend:** Monitor. If any word/clue page gets slow, add `will_paginate` with the existing
`per_page` settings. Not worth the complexity now.

### 8. Spec uses `should` syntax — **nitpick**
**Severity:** nitpick (test hygiene)
**Location:** `spec/controllers/words_controller_spec.rb`, `spec/models/word_spec.rb`,
`spec/models/clue_spec.rb`

These specs use `it { should respond_with(200) }` and `it {should have_many ...}`. Per
project rules, specs should use `expect()` syntax only.

**Fix:** When touching these files for other fixes, migrate to `expect()`:
```ruby
# Instead of: it { should respond_with(200) }
it { expect(response).to have_http_status(:ok) }

# Instead of: it {should have_many :clues}
it { is_expected.to have_many(:clues) }
```

### 9. No back-link from clue to word — **nitpick**
**Severity:** nitpick (navigation)

If you navigate Word → Clue, there's no visible link back to the word page. The fix in
item #4 (show the word on the clue page) addresses this.

---

## Implementation Order

1. **Items 1-3 (should-fix):** N+1 fix, page titles, SQL ordering — quick wins, no design decisions
2. **Items 4-6 (suggestions):** Word/clue page enrichment — add word link, letter count, difficulty
3. **Item 8 (nitpick):** Spec syntax migration — do alongside other spec changes

All changes are backward-compatible. No migrations needed. No new gems.

---

## Files to Touch

| File | Changes |
|------|---------|
| `app/models/word.rb` | `.includes(:user)` on `crosswords_by_title` |
| `app/models/clue.rb` | `.includes(:user)` on `crosswords_by_title` |
| `app/models/phrase.rb` | `.includes(:user)` on `crosswords_by_title` |
| `app/controllers/words_controller.rb` | `.order(:difficulty)` instead of `.sort_by` |
| `app/views/words/show.html.haml` | Add `title`, word length, difficulty indicators |
| `app/views/words/partials/_word.html.haml` | Add letter count subtitle |
| `app/views/clues/show.html.haml` | Add `title`, word link + length |
| `app/assets/stylesheets/_components.scss` | Add `.xw-prose__subtitle` and `.xw-difficulty` styles |
| `spec/controllers/words_controller_spec.rb` | Migrate `should` → `expect()` |
| `spec/models/word_spec.rb` | Migrate `should` → `expect()` |
| `spec/models/clue_spec.rb` | Migrate `should` → `expect()` |

---

## Test Plan

- Verify no N+1 queries on word/clue show pages (check logs for `SELECT * FROM users`)
- Verify `<title>` tag contains word/clue content (request spec)
- Verify clue page shows associated word link
- Verify word page shows letter count
- Run full suite: `bundle exec rspec`
