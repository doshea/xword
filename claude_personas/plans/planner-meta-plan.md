# Planner Work Queue

## Workflow

1. Pick an unreviewed item below
2. Write findings to `claude_personas/plans/<slug>.md` (severity-rated)
3. Update the item's status in this file
4. Add a short `Planner → Builder` entry on `shared.md` pointing to the plan file

---

## Phase 1 — Complete ✅

16 visual/UX reviews + backend audit. Deployed v548–v574.

<details>
<summary>Phase 1 items (archived)</summary>

| # | Item | Plan |
|---|------|------|
| 1–8 | Create Dashboard, New Puzzle Form, Solution Choice, Profile, Notifications, Word/Clue Detail, Search, NYT Calendar | Various |
| 9–12 | Login/Signup, Forgot Password, Account Settings, Admin Panel | Various |
| 13–16 | User-Made Puzzles, Team Solving, Test Suite Health, Backend Logic Audit | Various |
| — | Changelog (new feature) | `changelog-page.md` |

</details>

## Phase 2 — Complete ✅

7 items: DB constraints, a11y, service specs, API security, NYT pagination, JS cleanup, stats perf. Deployed v576–v578.

<details>
<summary>Phase 2 items (archived)</summary>

| # | Item | Plan |
|---|------|------|
| P2-1 | Database Constraints Migration | `db-constraints-migration.md` |
| P2-2 | Form Accessibility Audit | `form-accessibility-audit.md` |
| P2-3 | Service Object Test Coverage | `service-test-coverage.md` |
| P2-4 | API Security & Rate Limiting | `api-security-review.md` |
| P2-5 | NYT Page Pagination | `nyt-pagination.md` |
| P2-6 | JS Event Listener Cleanup | `js-event-listener-cleanup.md` |
| P2-7 | Stats Page Performance | `stats-page-performance.md` (no build needed) |

</details>

---

## Phase 3 — Solve Confidence & Performance Polish

Codebase is in excellent shape after P1+P2. Phase 3 targets the two remaining gaps:
users can't tell if their work saved (UX confidence), and two missing composite indexes
will become bottlenecks at scale (performance). Items ordered by ROI, not category.

**Principles:**
- Mechanical items go straight to Builder (no review cycle).
- Related problems merged into single items (not split across reviews).
- Admin-only and speculative features deferred to backlog.

### Status

| # | Item | Type | Status | Plan | Deploy |
|---|------|------|--------|------|--------|
| P3-A | Solve Confidence (save feedback + error visibility) | Review | ✅ Reviewed | `solve-confidence.md` | — |
| P3-B | Cell Navigation Composite Index | Direct | ⬚ Unreviewed | — | — |
| P3-C | Design Token Completion | Review | ✅ Reviewed | `design-token-completion.md` | — |
| P3-D | Dead Code Cleanup | Direct | ⬚ Unreviewed | — | — |
| P3-E | Loading State Spinners | Direct | ⬚ Unreviewed | — | — |
| P3-F | Random Puzzle Offset Fix | Direct | ⬚ Unreviewed | — | — |
| P3-G | Crossword User+Date Composite Index | Direct | ⬚ Unreviewed | — | — |
| P3-H | Solve Page Navigation (back button + mobile send) | Review | ⬚ Unreviewed | — | — |

### Deploy Sequence

**Deploy 1** — Quick wins (P3-D + P3-B + P3-G + P3-F): one migration, one commit.
**Deploy 2** — P3-A (solve confidence): headline item, full review cycle.
**Deploy 3** — P3-C + P3-E: visual consistency pass.
**Deploy 4** — P3-H: navigation polish.

---

### P3-A: Solve Confidence ★★★★★
Scope: `solve_funcs.js` (6 AJAX error handlers + save logic), `crossword.scss.erb`, ~45 min
Merged from old P3-4 (save feedback) + P3-5 (autosave feedback). Core user anxiety: *"Did my work save?"*

Three deliverables:
1. **AJAX error callbacks → `cw.flash()`**: 6 call sites (`check_cell`, `check_word`, `check_completion`, `reveal_cell`, `hint_word`, `save_solution`) currently `console.warn()` only. Replace with `cw.flash('Check failed. Please try again.', 'error')`. Users currently get zero feedback when network drops mid-check.
2. **Consecutive save failure banner**: Track failure count in `solve_app`. After 3 consecutive auto-save failures, show persistent red `cw.flash()` warning: "Unable to save — check your connection." Reset counter on success. Prevents silent data loss on flaky networks.
3. **Manual save success animation**: `.xw-btn--saved` CSS animation is **already defined** in `crossword.scss.erb:1269` but **never applied**. After successful manual save, add class to `#solve-save`, remove after animation completes. 5 min fix, immediate user reassurance.

Planner reviews: exact error message copy, animation timing, whether edit page save feedback also needs work.

### P3-B: Cell Navigation Composite Index ★★★★★
Scope: 1 migration file, ~10 min. **No review needed — direct builder task.**

Add composite index `(crossword_id, row, col)` on `cells` table. Every arrow-key press in the solve grid calls `find_by_row_and_col_and_crossword_id`. Currently PostgreSQL intersects three single-column indexes. Composite index = single B-tree lookup. This is the most-executed query in the app.

```ruby
add_index :cells, [:crossword_id, :row, :col], name: "index_cells_on_crossword_row_col"
```

### P3-C: Design Token Completion ★★★★
Scope: `_design_tokens.scss`, `_components.scss`, `_nav.scss`, ~30 min

Expanded from old P3-2. Audit found **12+ hardcoded colors**, not 8:
- 6× `#fff` / `color: white` in `_components.scss` (buttons, pagination, calendar hover)
- 3× `#fff` / `rgba(255,255,255,...)` in `_nav.scss` (badge, search input, dropdown hover)
- 3× `rgba(28,26,23,...)` and `#000` (modal backdrop, shadow, mask-image)

Action:
1. Create new tokens: `--color-text-inverse` (white-on-dark text), `--color-overlay-light: rgba(255,255,255,0.12)`, `--color-overlay-dark: rgba(28,26,23,0.6)`
2. Replace all 12+ instances with appropriate token
3. Planner verifies each: is it truly white-on-dark, or contextual surface color?

Why it matters: if the palette ever changes (dark mode, seasonal theme), every color responds automatically.

### P3-D: Dead Code Cleanup ★★★★
Scope: 3 files, ~5 min. **No review needed — direct builder task.**

- Remove `include TimeHelper` from `ApplicationHelper` — module doesn't exist
- Delete `UnpublishedCrossword#letters_to_clue_numbers` (47 lines) — `#TODO make this work`, never called
- Remove stale TODO comment in `pages/home.html.haml` about search.css

### P3-E: Loading State Spinners ★★★
Scope: 3 views, ~10 min. **No review needed — direct builder task.**

`xw-spinner` CSS class exists and works. Add it to the 3 places that show text-only "Loading...":
1. Home page "Load next X puzzles" button — add `<span class="xw-spinner"></span>` alongside text
2. NYT lazy tab placeholder — add spinner to "Loading…" text
3. Search form submit button — add spinner when loading controller activates

Mechanical: insert spinner markup, no new CSS needed.

### P3-F: Random Puzzle Offset Fix ★★★
Scope: `pages_controller.rb:131`, ~5 min. **No review needed — direct builder task.**

`Crossword.order("RANDOM()").first` does a full table sort. Replace with offset-based random:
```ruby
scope = Crossword.new_to_user(@current_user)
count = scope.count
@next_puzzle = count > 0 ? scope.offset(rand(count)).limit(1).first : nil
```
Prevents a scaling cliff when crossword count grows. Two queries (COUNT + OFFSET) vs. full sort.

### P3-G: Crossword User+Date Composite Index ★★★
Scope: 1 migration file, ~10 min. **No review needed — direct builder task.**

Home page runs 6 queries that filter by user and sort by `created_at`. Add composite index:
```ruby
add_index :crosswords, [:user_id, :created_at], order: { created_at: :desc },
          name: "index_crosswords_on_user_id_and_created_at"
```
Bundle into same migration as P3-B.

### P3-H: Solve Page Navigation ★★★
Scope: `show.html.haml` + `crossword.scss.erb`, ~20 min

Two items from old P3-4 that need minor design decisions:
1. **Back/home button**: Add `←` icon-button to puzzle toolbar linking home (or `history.back()`). On mobile, users feel trapped in the solve view with no visible exit.
2. **Mobile comment send button**: Add visible "Send" button below comment textarea. On mobile, pressing Enter in a textarea creates a newline — users don't know Shift+Enter (or Enter, depending on handler) submits. Button should use existing `.xw-btn--accent` style, hidden on desktop where Enter works.

Planner reviews: button placement in toolbar, send button visibility breakpoint.

---

## Deferred to Backlog

Moved from Phase 3 — not high enough ROI for this phase:

- **Admin Form Styling** (was P3-3) — 6 admin views used by ~1 person. Zero user impact. Revisit if admin usage grows.
- **Inline Form Validation** (was P3-7) — CSS classes exist but no form uses them. Current server-side validation + flash errors works. This is a feature (better UX), not a fix. Revisit if user drop-off is observed on signup/login.
- **Review Checklist** (was P3-8) — Good idea but the planner/builder workflow already serves this function at current team size. Create when a second builder is onboarded.

## Backlog (needs feature work or user decision)

- Clue Suggestions from Phrase DB — infrastructure ready, not planned
- `remotipart` replacement — needs Turbo file upload strategy
- Published column restoration — schema change needed
- Unfriend mechanism — no unfriend feature exists
- Admin Form Styling — low priority, single-user audience
- Inline Form Validation — feature, not fix; defer until user drop-off observed
- Review Checklist Template — create when team grows

## Low-Priority Carry-Forward

(cleared — all Phase 1/2 items deployed through v578)
