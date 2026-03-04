# Plan: Remove `Crossword` Default Scope

## Overview

Remove `default_scope -> { order(created_at: :desc) }` from `Crossword` model. This default scope silently prepends `ORDER BY created_at DESC` to every query, causing **3 active production bugs** and making code harder to reason about.

---

## Discovered Bugs (confirmed via SQL output)

### Bug 1: "Random puzzle" always returns the newest puzzle
```sql
-- Current (broken):
SELECT * FROM crosswords ORDER BY created_at DESC, RANDOM() LIMIT 1
-- RANDOM() never consulted because created_at has unique values
```
**Affected:** `PagesController#random_puzzle`, `User.rand_unowned_puzzle`

### Bug 2: Search results sorted by date, not relevance
```sql
-- Current (broken):
SELECT * FROM crosswords ... ORDER BY created_at DESC, pg_search_rank DESC
-- Relevance ranking from pg_search is secondary to date
```
**Affected:** `PagesController#search`, `PagesController#live_search`

### Bug 3: Admin crosswords page sorted DESC despite explicit ASC
```sql
-- Current (broken):
SELECT * FROM crosswords ORDER BY created_at DESC, created_at ASC
-- First DESC wins, admin always sees newest first
```
**Affected:** `Admin::CrosswordsController#index`

---

## Architecture

### Strategy: Explicit-order-everywhere, then delete

1. Add explicit `.order(created_at: :desc)` to every query that needs newest-first
2. Change `.order()` to `.reorder()` where the intent is to REPLACE ordering (random, admin ASC, search relevance)
3. Remove the default scope
4. Fix test specs that rely on implicit ordering
5. Clean up `.unscoped` calls that were workarounds for the default scope

### Why not keep it?

Default scopes are a well-known Rails anti-pattern:
- They infect every query silently — joins, subqueries, associations
- `.order()` appends instead of replacing, causing bugs 1-3 above
- Future developers won't know it exists until something breaks
- CLAUDE.md already flags it as "when, not if" bug source

---

## Files to change (8 files)

### Phase 1: Fix ordering at all call sites (no behavioral change yet)

#### 1. `app/models/crossword.rb` line 26 — DELETE default scope

```ruby
# DELETE THIS LINE:
default_scope -> { order(created_at: :desc) }
```

#### 2. `app/controllers/pages_controller.rb` — Add explicit ordering

**Lines 16-18** — Home page tabs (logged-in user). Add `.order(created_at: :desc)`:
```ruby
@unstarted   = Crossword.new_to_user(@current_user).order(created_at: :desc).includes(:user).limit(per)
@in_progress = Crossword.all_in_progress(@current_user).order(created_at: :desc).includes(:user).limit(per)
@solved      = Crossword.all_solved(@current_user).order(created_at: :desc).includes(:user).limit(per)
```

**Line 20** — Home page (anonymous user). Add `.order(created_at: :desc)`:
```ruby
@unstarted = Crossword.all.order(created_at: :desc).includes(:user).paginate(page: params[:page])
```

**Lines 50** — Search page results. **DON'T add date ordering** — let pg_search rank by relevance:
```ruby
# No change needed — after removing default scope, pg_search ranking
# will correctly be the primary sort. This FIXES Bug 2.
@crosswords = Crossword.starts_with(@query).includes(:user).load
```

**Line 60** — Live search. Same as above — let relevance rank:
```ruby
# No change needed — pg_search relevance ranking will be primary.
@crosswords = Crossword.starts_with(query).limit(max_results).load
```

**Lines 89-91** — Random puzzle. Change `.order` to `.reorder` to **fix Bug 1**:
```ruby
crossword = if @current_user
              Crossword.unowned(@current_user).reorder("RANDOM()").first
            else
              Crossword.reorder("RANDOM()").first
            end
```

**Note:** After removing default scope, `.order("RANDOM()")` would work too, but `.reorder()` is defensive — communicates intent explicitly.

**Line 120** — NYT puzzles page. Add `.order(created_at: :desc)`:
```ruby
@nytimes_puzzles = @nytimes_user ? @nytimes_user.crosswords.order(created_at: :desc).includes(:user) : Crossword.none
```

**Line 125** — User-made page. Add `.order(created_at: :desc)`:
```ruby
@user_puzzles = @nytimes_user ? Crossword.where.not(user_id: @nytimes_user.id).order(created_at: :desc).includes(:user) : Crossword.order(created_at: :desc).includes(:user).all
```

#### 3. `app/controllers/users_controller.rb` line 11 — User profile puzzles

Add `.order(created_at: :desc)`:
```ruby
@crosswords = @user.crosswords.order(created_at: :desc).paginate(page: params[:puzzles_page], per_page: 10)
```

#### 4. `app/controllers/crosswords_controller.rb` line 124 — Batch endpoint

Add `.order(created_at: :desc)`:
```ruby
@crosswords = Crossword.where(id: ids).order(created_at: :desc)
```

#### 5. `app/controllers/admin/crosswords_controller.rb` line 6 — Admin index

Change `.order(:created_at)` to `.order(created_at: :asc)` (explicit direction, **fixes Bug 3**):
```ruby
@crosswords = Crossword.includes(:user).order(created_at: :asc).paginate(page: params[:page])
```

**Note:** After removing default scope, `.order(:created_at)` would also correctly default to ASC, but explicit `:asc` communicates intent.

#### 6. `app/models/user.rb` lines 140-141 — `rand_unowned_puzzle`

Change `.order` to `.reorder` (defensive, same as pages_controller fix):
```ruby
def self.rand_unowned_puzzle(user = nil)
  user.present? ? Crossword.unowned(user).reorder("RANDOM()").first : Crossword.reorder("RANDOM()").first
end
```

### Phase 2: Fix test specs

#### 7. `spec/requests/unpublished_crosswords_spec.rb` — lines 42, 50, 61, 71

Replace `Crossword.last` with `Crossword.order(:created_at).last`:

```ruby
# Line 42:
crossword = Crossword.order(:created_at).last

# Line 50:
cw = Crossword.order(:created_at).last

# Line 61:
cw = Crossword.order(:created_at).last

# Line 71:
cw = Crossword.order(:created_at).last
```

**Why `.order(:created_at).last`:** These tests create a crossword via publish, then need to find the one just created. Without default scope, `.last` uses database natural order (not guaranteed). `.order(:created_at).last` explicitly gets the most recently created record.

### Phase 3: Clean up workarounds

#### 8. `spec/services/nyt_puzzle_importer_spec.rb` — lines 34, 58, 66
#### 9. `spec/services/crossword_publisher_spec.rb` — line 17

Replace `Crossword.unscoped.last` with `Crossword.order(:created_at).last`:

```ruby
# Was a workaround for default scope — no longer needed
crossword = Crossword.order(:created_at).last
```

**Optional but recommended:** `.unscoped` was only there to avoid the default scope. Removing it makes the intent clearer — we're just getting the most recent crossword.

---

## Call sites NOT changed (and why)

| Call site | Why no change needed |
|---|---|
| `CommentsController` — `Crossword.find_by(id:)` | Single record lookup, order irrelevant |
| `CrosswordsController` — `Crossword.find_by(id:)` | Single record lookup, order irrelevant |
| `Api::CrosswordsController` — `Crossword.find_by(title:)` | Single record lookup, order irrelevant |
| `NytPuzzleImporter` — `Crossword.where(title:).any?` | Existence check, order irrelevant |
| `Word#crosswords_by_title` | Already uses `.reorder(:title)` |
| `Phrase#crosswords_by_title` | Already uses `.reorder(:title)` |
| `Clue#crosswords_by_title` | Already uses `.reorder(:title)` |
| `Publishable` scopes | No internal ordering — controllers add it |
| `PagesController` `.count` calls (lines 13-15) | Aggregate, order irrelevant |

---

## Execution order

| # | Step | Files | Risk |
|---|---|---|---|
| 1 | Add explicit `.order(created_at: :desc)` to 6 controller call sites | pages, users, crosswords, admin controllers | None — same behavior as today |
| 2 | Change `.order("RANDOM()")` → `.reorder("RANDOM()")` | pages_controller, user.rb | **Bug fix** — random actually random now |
| 3 | Change admin `.order(:created_at)` → `.order(created_at: :asc)` | admin/crosswords_controller | **Bug fix** — admin sort now ASC as intended |
| 4 | Delete default scope | crossword.rb line 26 | **The switch.** All queries now use explicit or pg_search ordering. |
| 5 | Fix test specs | unpublished_crosswords_spec | Tests pass with explicit ordering |
| 6 | Clean up `.unscoped` workarounds | nyt_puzzle_importer_spec, crossword_publisher_spec | Clarity improvement, not behavioral |

**Critical:** Steps 1-3 should be done BEFORE step 4 to ensure zero behavioral regression (except the 3 bug fixes). Step 4 is the actual scope deletion. Steps 5-6 fix tests.

---

## Risks & mitigations

| Risk | Severity | Mitigation |
|---|---|---|
| Missed call site | Medium | Comprehensive audit found ~40 sites. Run `bundle exec rspec` after step 4 to catch any failures. Manual spot-check of home page, search, profile. |
| Publishable `.union()` scopes | Low | Union scopes don't rely on ordering — controllers add `.order()` after the scope chain. Verified: `.count`, `.limit()`, `.distinct` are order-agnostic. |
| Association queries (`.crosswords`) | Low | Only used via `crosswords_by_title` (which reorders) or with explicit `.order()` added in step 1. |
| pg_search relevance change | Low-positive | **Intentional fix.** Search results will now sort by relevance, which is correct behavior. Users may notice improved search quality. |
| Random puzzle change | Low-positive | **Intentional fix.** `/random` will now actually return random puzzles. |

---

## Acceptance criteria

1. `bundle exec rspec` — all examples pass, 0 failures
2. Home page tabs show newest puzzles first (same as today)
3. `/random` returns genuinely random puzzles (fixed!)
4. Search results sort by relevance, not date (fixed!)
5. Admin crosswords page sorts oldest-first (fixed!)
6. User profile shows their puzzles newest-first (same as today)
7. NYT / User-made pages show newest-first (same as today)
8. No `default_scope` in `crossword.rb`
9. No `.unscoped` workarounds remaining in test specs

---

## Verification checklist (manual)

After `rspec` passes, manually verify in browser:
- [ ] Home page: logged in → puzzles in each tab are newest-first
- [ ] Home page: anonymous → puzzles are newest-first, pagination works
- [ ] Search: type a word → results should be relevant, not just newest
- [ ] Random: click "Random" 3 times → should get different puzzles
- [ ] Profile: view a user's puzzles → newest-first
- [ ] NYT page: puzzles are newest-first
- [ ] Admin crosswords: puzzles are oldest-first (creation order)
- [ ] Publish a crossword: redirects correctly to the new puzzle

---

# Plan: Puzzle Card BEM Rename

## Overview

Rename legacy class names in the `_crossword_tab` partial and its CSS from generic names (`.result-crossword`, `.minipic`, `.metadata`, `.title`, `.byline`, `.dimensions`) to BEM-namespaced `.xw-puzzle-card` pattern. Also rename `.puzzle-tabs` → `.xw-puzzle-grid`.

**This is a mechanical rename with no behavioral or visual change.** Pure code quality.

---

## Class name mapping

| Old | New | Element |
|---|---|---|
| `.puzzle-tabs` | `.xw-puzzle-grid` | Grid container context |
| `.result-crossword` | `.xw-puzzle-card` | Card root |
| `.minipic` | `.xw-puzzle-card__thumb` | Image column |
| `.metadata` | `.xw-puzzle-card__meta` | Text column |
| `.title` | `.xw-puzzle-card__title` | Puzzle title |
| `.byline` | `.xw-puzzle-card__byline` | Creator attribution |
| `.dimensions` | `.xw-puzzle-card__dims` | Rows × cols |
| `.nyt-watermark` | `.xw-puzzle-card__nyt` | NYT logo badge |

---

## Files to change (12 files)

### 1. Partial — `app/views/crosswords/partials/_crossword_tab.html.haml`

```haml
- unpublished = (defined?(unpublished) && unpublished == true)
= link_to (unpublished ? edit_unpublished_crossword_path(cw) : crossword_path(cw)) do
  .xw-puzzle-card
    .xw-grid
      .xw-col-12.xw-lg-4.xw-puzzle-card__thumb
        = image_tag cw.try(:preview_url) || asset_path('example_puzzle.jpg'), class: "xw-thumbnail cols-#{cw.cols} rows-#{cw.rows}#{' unpublished' if unpublished}"
      .xw-col-12.xw-lg-8.xw-puzzle-card__meta
        %p.xw-puzzle-card__title= cw.title
        - unless unpublished or cw.user.nil? or (cw.user.username == 'nytimes')
          %p.xw-puzzle-card__byline= "by #{cw.user.display_name}"
        %p.xw-puzzle-card__dims= "#{cw.rows} x #{cw.cols}"
      - if (cw.user&.username == 'nytimes')
        = image_tag 'nyt_black.png', class: 'xw-puzzle-card__nyt'
```

### 2. CSS — `app/assets/stylesheets/_components.scss` lines 843-937

Rename all selectors:
- `.puzzle-tabs` → `.xw-puzzle-grid`
- `.result-crossword` → `.xw-puzzle-card`
- `.minipic` → `.xw-puzzle-card__thumb`
- `.metadata` → `.xw-puzzle-card__meta`
- `.title` → `.xw-puzzle-card__title`
- `.byline` → `.xw-puzzle-card__byline`
- `.dimensions` → `.xw-puzzle-card__dims`
- `.nyt-watermark` → `.xw-puzzle-card__nyt`
- **DELETE** lines 931-937 (`.puzzle-tabs .xw-tabs__nav` — dead code, no matching HTML)

### 3. View spec — `spec/views/crosswords/partials/_crossword_tab.html.haml_spec.rb`

Update assertions:
- `have_selector('.result-crossword')` → `have_selector('.xw-puzzle-card')`

### 4-11. Views that pass `columns_class: 'puzzle-tabs'` — Change to `'xw-puzzle-grid'`

These views pass `columns_class` to the `topper_stopper` layout. Update the string:

| File | Change |
|---|---|
| `app/views/create/dashboard.html.haml` | `columns_class: 'puzzle-tabs'` → `'xw-puzzle-grid'` |
| `app/views/pages/nytimes.html.haml` | `columns_class: 'puzzle-tabs'` → `'xw-puzzle-grid'` |
| `app/views/pages/user_made.html.haml` | `columns_class: 'puzzle-tabs'` → `'xw-puzzle-grid'` |

**Note:** `clues/show.html.haml` and `words/show.html.haml` render `_crossword_tab` inside `.xw-prose` — they use the partial but not the `.puzzle-tabs` grid wrapper. No `columns_class` change needed there.

### 12. Home page list — `app/views/pages/home/_crossword_list.html.haml`

Check if it wraps cards in `.puzzle-tabs` — if so, rename to `.xw-puzzle-grid`.

---

## What stays the same

- **`.xw-thumbnail`** class on the `<img>` — this is a separate utility class in `global.scss.erb`
- **`.unpublished`** modifier on the image — applied conditionally, unchanged
- **`.xw-grid` / `.xw-col-12` / `.xw-lg-4` / `.xw-lg-8`** — grid utility classes, unchanged
- **All visual appearance** — purely a class rename, identical CSS properties

## Risk

**Very low.** Mechanical find-and-replace. No JS references. No behavioral change. Run `rspec` to catch any broken assertions.

## Acceptance criteria

1. `bundle exec rspec` passes — all examples including view spec
2. All puzzle card lists render identically (visual spot-check: home, NYT, user-made, create dashboard, word/clue show)
3. No remaining references to `.result-crossword`, `.minipic`, `.metadata .title`, `.metadata .byline`, `.metadata .dimensions`, `.nyt-watermark` in SCSS or HAML
4. Dead CSS block (`.puzzle-tabs .xw-tabs__nav`) is deleted
