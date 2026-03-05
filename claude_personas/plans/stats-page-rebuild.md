# Stats Page Rebuild

## Summary

Replace the current stats page (two user-signup line charts) with a community dashboard
showing 6 sections of aggregate site stats. All queries are simple COUNT/GROUP BY on indexed
columns — no expensive joins, no full scans on large tables.

**Safety rule:** Only aggregate numbers. Never expose individual user activity, solve times,
or personal data. Everything shown is either already public (puzzle titles, creator usernames)
or a site-wide aggregate.

**Progressive disclosure:** Each section has a minimum-data threshold. Sections with
insufficient data don't render — no sad "0%" rows or empty leaderboards.

---

## Files to Touch

| File | Change |
|------|--------|
| `app/controllers/pages_controller.rb` | Expand `#stats` action with ~10 queries |
| `app/views/pages/stats.html.haml` | Full rewrite — 6 sections |
| `app/assets/stylesheets/site_stats.scss` | New styles for stat cards, leaderboards |
| `app/assets/javascripts/controllers/stats_controller.js` | Add bar/donut chart type support |

No new files, no new gems, no migrations.

---

## Section 1: At a Glance (hero number cards)

**Always shown.** Four big-number cards in a responsive row.

| Card | Query | Current Value |
|------|-------|---------------|
| Puzzles Published | `Crossword.count` | 15 |
| Solves Completed | `Solution.where(is_complete: true).count` | 3 |
| Community Members | `User.where(deleted_at: nil).count` | 5 |
| Clues Written | `Clue.count` | 4,974 |

**Design:** Centered row of 4 cards (2×2 on mobile). Each card: large number in
`--font-display` at `--text-4xl`, label below in `--font-ui` at `--text-sm`,
`--color-text-secondary`. Cards use `--color-surface-alt` background with `--radius-lg`.

**Query cost:** 4 index-only COUNT queries. Sub-millisecond each.

---

## Section 2: Growth Over Time (line charts)

**Always shown.** Keep the existing two charts (Total Users, Daily Signups) and add a
third: **Puzzles Published Over Time** (cumulative running total, same pattern).

New query:
```ruby
puzzle_counts = Crossword.group("DATE(created_at)").order("DATE(created_at)").count
```

Same label-thinning logic (show 1st and 15th of month). Same Chart.js line config.

**Query cost:** 1 additional GROUP BY on indexed `crosswords.created_at`.

---

## Section 3: Puzzle Variety — Grid Size Distribution

**Show when:** `Crossword.count >= 5` (currently 15 — will show).

Horizontal bar chart showing puzzle count per grid size.

```ruby
@grid_sizes = Crossword.group(:rows, :cols).order(:rows).count
# => {[7,7]=>1, [9,9]=>2, [11,11]=>3, [13,13]=>2, [15,15]=>7}
```

Display as a horizontal bar chart. Labels: "7×7", "9×9", etc. Bars use `--color-accent`.

**Query cost:** Seq scan on 15-row table, grouped. Trivial at any realistic scale.

---

## Section 4: Solving Activity (stat row)

**Show when:** `Solution.count >= 5` (currently 15 — will show).

Three inline stats displayed as a `<dl>` with large values:

| Stat | Computation | Current |
|------|-------------|---------|
| Completion Rate | `completed / total solutions * 100` | 20% |
| Avg Solvers per Puzzle | `Solution.count / Crossword.count` | 1.0 |
| Hint-Free Completions | `completed_no_hints / completed * 100` | 100% |

```ruby
@total_solutions    = Solution.count
@completed_count    = Solution.where(is_complete: true).count
@completion_rate    = (@completed_count.to_f / @total_solutions * 100).round(0) if @total_solutions > 0
@avg_solvers        = (@total_solutions.to_f / Crossword.count).round(1) if Crossword.count > 0
@hintfree_count     = Solution.where(is_complete: true, hints_used: 0).count
@hintfree_rate      = (@hintfree_count.to_f / @completed_count * 100).round(0) if @completed_count > 0
```

**Hide hint-free row** when `@completed_count == 0`.

**Design:** Three stat blocks in a centered flex row (stack on mobile).
Number in `--text-3xl --font-display`, label below in `--text-sm --font-ui`.

**Query cost:** 3-4 COUNT queries on indexed columns. Sub-millisecond.

---

## Section 5: Popular Puzzles (top 5 table)

**Show when:** At least 3 puzzles have ≥1 solution (currently yes — will show).

Top 5 most-solved puzzles, showing title (linked), creator username, grid size, solver count.

```ruby
@popular_puzzles = Crossword
  .select("crosswords.*, COUNT(solutions.id) as solver_count")
  .joins(:solutions)
  .group("crosswords.id")
  .order("solver_count DESC")
  .includes(:user)
  .limit(5)
```

**Design:** Styled `<table>` or `<dl>` list. Rank number, linked puzzle title, "by username",
grid size badge, solver count. Use `.xw-prose` table styles or a custom `.xw-stats-table`.

**Query cost:** Single JOIN + GROUP on indexed `solutions.crossword_id`. Fast at any scale.

---

## Section 6: Prolific Constructors (top 5 table)

**Show when:** At least 3 distinct users have published puzzles (currently 5 — will show).

Top 5 creators by puzzle count.

```ruby
@top_creators = User
  .select("users.username, COUNT(crosswords.id) as puzzle_count")
  .joins(:crosswords)
  .where(deleted_at: nil)
  .group("users.id")
  .order("puzzle_count DESC")
  .limit(5)
```

**Design:** Same table/list style as Popular Puzzles. Rank, username (linked to profile),
puzzle count.

**Query cost:** Single JOIN + GROUP on indexed `crosswords.user_id`. Trivial.

---

## What NOT to Show (and Why)

| Stat | Reason |
|------|--------|
| Individual solve times | Privacy — no opt-in for speed ranking |
| Per-user solve counts | Competitive pressure discourages casual users |
| Flagged comments | Draws attention to moderation issues |
| Friend/social stats | Privacy — reveals social graph |
| Abandoned solve counts | Shames people who didn't finish |
| Newest members / recently active | Timestamps + usernames = activity surveillance |
| Clue difficulty distribution | All 4,974 clues are difficulty=1 (default). Useless |

---

## Performance

All queries combined: ~8-10 simple COUNT/GROUP BY queries on indexed columns.

| Scale | Est. total query time |
|-------|----------------------|
| Current (15 puzzles, 15 solutions) | <5ms |
| 10× (150 puzzles, 150 solutions) | <10ms |
| 100× (1,500 puzzles, 1,500 solutions) | <50ms |
| 1000× (15K puzzles, 15K solutions) | <200ms — add `Rails.cache.fetch` at this point |

No `cells` table queries. No text-column aggregations. No subqueries.

---

## Page Layout (top to bottom)

```
┌─────────────────────────────────────────────────┐
│  h1: Site Stats  (topper_stopper)               │
├─────────────────────────────────────────────────┤
│                                                 │
│  ┌────────┐ ┌────────┐ ┌────────┐ ┌────────┐   │
│  │   15   │ │    3   │ │    5   │ │ 4,974  │   │
│  │Puzzles │ │Solved  │ │Members │ │ Clues  │   │
│  └────────┘ └────────┘ └────────┘ └────────┘   │
│                                                 │
│  ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─  │
│                                                 │
│  h2: Growth                                     │
│  [Total Users chart ~~~~~~~~~~~~~~~~~~~~~~~~]   │
│  [Daily Signups chart ~~~~~~~~~~~~~~~~~~~~~~]   │
│  [Puzzles Published chart ~~~~~~~~~~~~~~~~~~]   │
│                                                 │
│  ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─  │
│                                                 │
│  h2: Puzzle Variety                             │
│  15×15  ████████████████████  7                 │
│  11×11  ████████             3                  │
│  13×13  █████                2                  │
│   9×9   █████                2                  │
│   7×7   ██                   1                  │
│                                                 │
│  ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─  │
│                                                 │
│  h2: Solving                                    │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐      │
│  │   20%    │  │   1.0    │  │  100%    │      │
│  │Completion│  │Avg Solver│  │Hint-Free │      │
│  │  Rate    │  │per Puzzle│  │Completions│     │
│  └──────────┘  └──────────┘  └──────────┘      │
│                                                 │
│  ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─  │
│                                                 │
│  h2: Most Popular Puzzles                       │
│  1. Interstellar Travel — by alocke (15×15) 5   │
│  2. Rage Cage — by doshea (15×15) ........  2   │
│  3. ...                                         │
│                                                 │
│  ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─  │
│                                                 │
│  h2: Top Constructors                           │
│  1. alocke ............................ 5        │
│  2. doshea ............................ 4        │
│  3. spark ............................. 2        │
│  4. jchen ............................. 2        │
│  5. msantos ........................... 2        │
│                                                 │
│  ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─  │
│                                                 │
│  [Browse Puzzles →]  CTA button                 │
│                                                 │
└─────────────────────────────────────────────────┘
```

---

## Style Notes

- Follow About page pattern: content arc with sections separated by `<hr>`, ending CTA
- Hero cards: CSS Grid `repeat(auto-fit, minmax(140px, 1fr))` — 4-up on desktop, 2×2 on mobile
- Leaderboard tables: minimal styling, no heavy borders — use `--color-border` bottom borders only
- Bar chart for grid sizes can be pure CSS (no Chart.js needed) — `<div>` bars with percentage widths.
  OR use Chart.js horizontal bar. Builder's choice — CSS bars are simpler and lighter.
- All text uses design tokens. No hardcoded colors or fonts.

---

## Acceptance Criteria

1. Stats page loads with all 6 sections populated from real data
2. Sections with insufficient data are hidden (not shown empty)
3. No individual user data exposed (solve times, activity patterns)
4. All numbers match database reality (spot-check with rails console)
5. Page renders correctly on mobile (375px), tablet (768px), desktop (1440px)
6. No N+1 queries — verify with `bullet` or `ActiveSupport::Notifications`
7. Total query time <50ms in development (check with `rails server` logs)
8. Charts render with existing Chart.js + Stimulus infrastructure
9. Existing specs pass; add request spec for `GET /stats` response
10. Uses design tokens throughout — no hardcoded colors/fonts/spacing

---

## Risks

- **Low:** The `xw-hr--accent` class used in current stats.html.haml is undefined (noted in
  info-pages-review.md). Builder should use plain `%hr` or define the class.
- **Low:** If a user deletes their account (`deleted_at` set), their puzzles and solutions
  remain. The "Community Members" count filters on `deleted_at: nil` but puzzle/solve counts
  include deleted users' contributions. This is correct behavior (the content exists) but
  worth noting.
