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
| P3-A | Solve Confidence (save feedback + error visibility) | Review | ✅ Done | `solve-confidence.md` | Deploy 2 (a1c069e) |
| P3-B | Cell Navigation Composite Index | Direct | ✅ Done | — | Deploy 1 (924e958) |
| P3-C | Design Token Completion | Review | ✅ Done | `design-token-completion.md` | Deploy 2 (a1c069e) |
| P3-D | Dead Code Cleanup | Direct | ✅ Done (partial) | — | Deploy 1 (924e958) |
| P3-E | Loading State Spinners | Review | ✅ Done | `loading-state-spinners.md` | Deploy 3 (ccd7556) |
| P3-F | Random Puzzle Offset Fix | Direct | ✅ Done | — | Deploy 1 (924e958) |
| P3-G | Crossword User+Date Composite Index | Direct | ✅ Done | — | Deploy 1 (924e958) |
| P3-H | Solve Page Navigation (back button + mobile send) | Review | ✅ Done | `solve-page-navigation.md` | Deploy 3 (ccd7556) |

### Deploy Sequence

**Deploy 1** ✅ — Quick wins (P3-D + P3-B + P3-G + P3-F): `924e958`
**Deploy 2** ✅ — P3-A + P3-C (solve confidence + design tokens): `a1c069e`
**Deploy 3** ✅ — P3-E + P3-H (loading spinners + navigation polish): `ccd7556`

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

---

## Phase 4 — Features & Tech Debt Cleanup

New features and the last jQuery gem dependency. Phases 1-3 were polish/hardening;
Phase 4 adds real functionality.

**Principles:**
- Mini-manuals first (highest user-facing impact, no backend risk)
- Clue suggestions next (leverages existing 53K phrase infrastructure)
- Unfriend before remotipart (user-facing feature before internal cleanup)
- Remotipart last (may be a 5-minute gem removal — test first)

### Status

| # | Item | Type | Status | Plan | Deploy |
|---|------|------|--------|------|--------|
| P4-A | Solve Page Mini-Manual | Feature | ✅ Done | `solve-mini-manual.md` | Deploy 4 (db957a1) |
| P4-B | Edit Page Mini-Manual | Feature | ✅ Done | `edit-mini-manual.md` | Deploy 4 (db957a1) |
| P4-C | Clue Suggestions from Phrase DB | Feature | ✅ Done | `clue-suggestions.md` | Deploy 4 (db957a1) |
| P4-D | Unfriend | Feature | ✅ Done | `unfriend.md` | Deploy 4 (db957a1) |
| P4-E | Remotipart Removal | Tech Debt | ✅ Done | `remotipart-replacement.md` | Deploy 4 (db957a1) |

### Deploy Sequence

**Deploy 4** ✅ — All Phase 4 items (P4-A through P4-E): `db957a1`

Note: Builder batched all 5 items into a single deploy. Solve mini-manual further polished in v582 (0b7f596).

### P4-A: Solve Page Mini-Manual ★★★★★
Scope: `show.html.haml` (replace `#controls-modal` content), `crossword.scss.erb`, ~30 min.

Replace the existing 4-line keyboard legend with a full "How to Solve" dialog covering:
navigation (6 shortcuts), entering letters, checking work (4 modes), getting help (reveal/hint),
saving (manual + auto), comments, and team solving (conditional). Uses `<kbd>` keycap styling.

### P4-B: Edit Page Mini-Manual ★★★★★
Scope: `edit.html.haml`, `edit_funcs.js`, shared CSS, ~30 min.

New feature — edit page has no existing help modal. Add `info` icon button to toolbar,
opening "How to Edit" dialog covering: navigation, grid filling (void toggle, mirror, circle
mode), writing clues, finding words (pattern search + notepad), saving/publishing, and
Advanced Controls reference.

### P4-C: Clue Suggestions ★★★★
Scope: `api_controller.rb`, `edit_funcs.js`, `_clue_column.html.haml`, `crossword.scss.erb`, ~2 hrs.

Inline popover on edit page. Lightbulb icon appears next to clue textarea when word is fully
filled. Click opens dropdown showing top 10 previously-used phrases for that word (from 53K
phrase DB), ordered by usage count. Click suggestion → fills textarea. Client-side cache per word.
New JSON endpoint at `GET /api/clue_suggestions?word=OREO`.

### P4-D: Unfriend ★★★
Scope: `friendship_service.rb`, `friend_requests_controller.rb`, `_friend_status.html.haml`, routes, ~45 min.

Dropdown on "Friends" button → "Unfriend" with confirmation. Deletes Friendship record only.
Shared solutions and notifications preserved (SolutionPartnering is independent). Turbo Stream
replaces status to `:none`. Re-friending allowed immediately.

### P4-E: Remotipart Removal ★★★
Scope: `Gemfile`, possibly `application.js`, ~30 min (mostly testing).

Remove `remotipart` gem. Turbo handles `multipart/form-data` natively. Only one form affected
(profile picture upload). Test thoroughly — if Turbo doesn't handle it, fall back to Active
Storage direct upload (detailed in plan). Removes last jQuery gem dependency.

---

## Deferred to Backlog

Moved from Phase 3 — not high enough ROI:

- **Admin Form Styling** (was P3-3) — 6 admin views used by ~1 person. Zero user impact.
- **Inline Form Validation** (was P3-7) — CSS classes exist but unused. Feature, not fix.
- **Review Checklist** (was P3-8) — Planner/builder workflow suffices at current team size.

## Backlog (needs feature work or user decision)

- Published column restoration — schema change needed
- Admin Form Styling — low priority, single-user audience
- Inline Form Validation — feature, not fix; defer until user drop-off observed
- Review Checklist Template — create when team grows
- Turbo Stream `replace` pattern bug (password errors) — 2-line fix, documented in planner memory but never queued

## Low-Priority Carry-Forward

(cleared — all Phase 1/2 items deployed through v578)
