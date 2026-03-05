# P2-7: Stats Page Performance Review

## Verdict: No Builder Work Needed Now

Current scale (5 users, 15 crosswords, 14 solutions) makes every query sub-millisecond.
Total page load query time: <1ms. This is a **monitor-and-act-later** situation, not an
immediate build task.

---

## Current State

### Query Inventory (11 queries, zero caching)

| # | Query | Exec Time | Indexed? |
|---|-------|-----------|----------|
| 1 | `Crossword.count` | 0.02ms | seq scan (15 rows) |
| 2 | `Solution.where(is_complete: true).count` | 0.03ms | has `(user_id, is_complete)` composite |
| 3 | `User.where(deleted_at: nil).count` | 0.02ms | **NO index on deleted_at** |
| 4 | `Clue.count` | ~0.1ms | seq scan (4974 rows) |
| 5 | `User.group(DATE(created_at)).count` | 0.07ms | **NO index on created_at** |
| 6 | `Crossword.group(DATE(created_at)).count` | ~0.02ms | ✓ indexed |
| 7 | `Crossword.group(:rows, :cols).count` | ~0.02ms | seq scan (15 rows) |
| 8 | `Solution.count` | ~0.02ms | seq scan (14 rows) |
| 9 | `Solution.where(is_complete: true, hints_used: 0).count` | 0.03ms | **NO composite index** |
| 10 | `Crossword.joins(:solutions).group.order.limit(5)` | ~0.05ms | FK indexes exist |
| 11 | `User.joins(:crosswords).where(deleted_at: nil).group.order.limit(5)` | ~0.05ms | FK indexed, deleted_at not |

**Total: ~0.5ms.** Redis cache configured in production but unused by this page.

### Architecture

- Growth charts build cumulative running totals in Ruby (iterate every day since launch)
- Currently 1 day of data → 1 iteration. At 5 years → 1825 iterations (still cheap)
- Chart.js v4.5.1 renders 3 line charts client-side via Stimulus controller
- Sections conditionally render (progressive disclosure with min-data thresholds)
- `.includes(:user)` on popular puzzles prevents N+1

---

## Missing Indexes (severity rated)

### 1. `users.deleted_at` — suggestion

Used by queries #3 and #11. Currently seq scans 5 rows. At 10K users, a partial index
would help:

```sql
CREATE INDEX index_users_on_active WHERE deleted_at IS NULL;
```

**Not urgent.** At current scale, Postgres will seq scan regardless (table fits in one page).
The P2-1 migration doesn't include this. Worth adding when users table exceeds ~1000 rows.

### 2. `users.created_at` — nitpick

Used by query #5 (growth chart GROUP BY). Even at 10K users, this GROUP BY returns ~365
rows/year — Postgres handles it efficiently with a sort. An index only helps if we need
ordered range scans (we don't — we want all rows grouped).

**Skip.** GROUP BY benefits more from parallel seq scan than a B-tree index.

### 3. `solutions(is_complete, hints_used)` — nitpick

Used by query #9. The existing `(user_id, is_complete)` index doesn't help this query
(wrong leading column). A dedicated index would help:

```sql
CREATE INDEX index_solutions_on_completion_hints ON solutions (is_complete)
  WHERE is_complete = true;
```

**Skip for now.** 14 rows. Add when solutions exceed ~5000.

---

## Scaling Recommendations (act when thresholds hit)

### Threshold 1: ~500 solutions / ~100 users → Add `Rails.cache.fetch`

Highest ROI change. Wrap the entire `stats` action body:

```ruby
def stats
  cache_data = Rails.cache.fetch('stats:page_data', expires_in: 30.minutes) do
    # ... all current query logic ...
    { puzzles_count:, completed_count:, members_count:, ... }
  end
  cache_data.each { |k, v| instance_variable_set("@#{k}", v) }
end
```

This eliminates ALL 11 queries for 30 minutes. Redis is already configured.
Manual cache bust: `Rails.cache.delete('stats:page_data')` from console if needed.

### Threshold 2: ~5000 solutions → Add targeted indexes

- Partial index on `users` WHERE `deleted_at IS NULL`
- Partial index on `solutions` WHERE `is_complete = true`

### Threshold 3: ~2 years of data → SQL window functions

Replace Ruby cumulative sum with:

```sql
SELECT DATE(created_at), SUM(COUNT(*)) OVER (ORDER BY DATE(created_at)) AS running_total
FROM users GROUP BY DATE(created_at) ORDER BY DATE(created_at)
```

Eliminates Ruby iteration over 730+ day range.

### Threshold 4: ~15K crosswords → counter_cache

Add `solutions_count` counter cache column to `crosswords` table. Eliminates the
popular puzzles JOIN/GROUP query entirely.

---

## What's Already Good

- **Progressive disclosure**: sections hide when data is insufficient (no empty states)
- **No N+1**: `.includes(:user)` on popular puzzles, all other queries are aggregates
- **Chart.js animation disabled**: `animation: false` — no layout thrash
- **Conditional queries**: hint-free and leaderboard queries only run when thresholds met
- **Data safety**: no individual user data exposed

## What's NOT a Problem

- **`Clue.count` seq scan (4974 rows)**: COUNT(*) on a table this size is ~0.1ms. Postgres
  doesn't use indexes for full-table COUNT anyway (MVCC requires row visibility checks).
- **Ruby running totals**: At 1 day of data, this is 1 iteration. Even at 5 years it's 1825
  integer additions — microseconds.
- **Chart.js payload**: chart.umd.min.js is a vendor asset, cached by browser. No per-page cost.

---

## Test Coverage

Current spec is smoke-test only:

```ruby
describe 'GET /stats' do
  it 'renders with users in the database' do
    create(:user)
    get '/stats'
    expect(response).to have_http_status(:ok)
  end
end
```

**Suggestion (not blocking):** Add specs for conditional section rendering:
- Empty database → only hero cards render
- With solutions → solving section appears
- With multiple creators → leaderboard appears

---

## Decision

**No Builder task.** File this review as reference for future scaling decisions. The two
actionable items are:

1. **Monitor**: When the site grows past ~500 solutions, add `Rails.cache.fetch` (30 min TTL)
2. **Optional**: Add `users.deleted_at` partial index to the next migration batch

Neither is urgent enough to warrant a standalone build task.
