# Planner Work Queue

## Workflow

1. Pick an unreviewed item below
2. Write findings to `claude_personas/plans/<slug>.md` (severity-rated)
3. Update the item's status in this file
4. Add a short `Planner → Builder` entry on `shared.md` pointing to the plan file

---

## Phase 1 — Complete ✅

All 16 visual/UX reviews + backend audit completed and deployed (v548–v574).
145 files changed, 6427 insertions, 1614 deletions. 967 examples, 0 failures, 90.28% coverage.

<details>
<summary>Phase 1 status table (archived)</summary>

| # | Item | Plan |
|---|------|------|
| 1 | Create Dashboard | `create-dashboard-review.md` |
| 2 | New Puzzle Form | `new-puzzle-form-review.md` |
| 3 | Solution Choice Page | `solution-choice-review.md` |
| 4 | Profile Page | `profile-page-review.md` |
| 5 | Notifications Full Page | `notifications-full-page-review.md` |
| 6 | Word/Clue Detail Pages | `word-clue-detail-review.md` |
| 7 | Search Page | `search-page-review.md` |
| 8 | NYT Page / Calendar | `nyt-calendar-review.md` |
| 9 | Login / Signup | `login-signup-review.md` |
| 10 | Forgot / Reset Password | `forgot-reset-password-review.md` |
| 11 | Account Settings | `account-settings-review.md` |
| 12 | Admin Panel | `admin-panel-review.md` |
| 13 | User-Made Puzzles Page | `user-made-page-review.md` |
| 14 | Team Solving UX | `team-solving-review.md` |
| 15 | Test Suite Health | `test-suite-health.md` |
| 16 | Backend Logic Audit | `backend-logic-audit.md` |
| — | Changelog (new feature) | `changelog-page.md` |

</details>

---

## Phase 2 — Data Integrity, Accessibility, Test Gaps

Surfaced by full-codebase audit after Phase 1 completion. Organized by risk.

### Status

| # | Item | Type | Status | Plan |
|---|------|------|--------|------|
| P2-1 | Database Constraints Migration | Review | ✅ Reviewed | `db-constraints-migration.md` |
| P2-2 | Form Accessibility Audit | Review | ✅ Reviewed | `form-accessibility-audit.md` |
| P2-3 | Service Object Test Coverage | Review | ✅ Reviewed | `service-test-coverage.md` |
| P2-4 | API Security & Rate Limiting | Review | ⬚ Unreviewed | — |
| P2-5 | NYT Page Pagination | Review | ⬚ Unreviewed | — |
| P2-6 | JS Event Listener Cleanup | Review | ⬚ Unreviewed | — |
| P2-7 | Stats Page Performance | Review | ⬚ Unreviewed | — |

### Tier 1 — Data Integrity (prevents real data bugs)

**P2-1: Database Constraints Migration**
Scope: 1 migration, model validation updates
- Add UNIQUE index on `users(email)` and `users(username)` — currently app-only, race condition risk
- Add UNIQUE composite on `friendships(user_id, friend_id)` — no PK, no unique constraint
- Add UNIQUE composite on `friend_requests(sender_id, recipient_id)` — same problem
- Add index on `notifications(actor_id)` — only FK column without an index
- Drop dead `cell_edits` table — model deleted in Phase 1, table still in schema
- Rescue `RecordNotUnique` in `FavoritePuzzle` and `SolutionPartnering` `find_or_create_by` calls
- Review: planner audits which constraints need `NOT NULL` vs staying nullable, checks for data that would violate new constraints before migration

**P2-4: API Security & Rate Limiting**
Scope: controller changes, possibly Rack::Attack gem
- `/api/users/index` returns all users (names, usernames, timestamps) with zero auth — enumeration risk
- No rate limiting on `/search` or `/live_search` — DoS vector
- CSP entirely commented out — no XSS protection headers
- Review: planner decides auth-gate vs remove vs scope-down for API, evaluates Rack::Attack vs custom throttle

### Tier 2 — Accessibility (user-facing quality)

**P2-2: Form Accessibility Audit**
Scope: ~10 view files, 0 migration
- 6+ forms missing `<label>` or `aria-label`: comment textareas (show page, win modal, reply), team chat input, clue edit fields, pattern search input
- Secondary pages (contact, faq) missing `<main>` landmark roles
- Reply buttons use `<a>` instead of `<button>` — semantic issue
- Edit page "Ideas" and "Pattern search" inputs have no labels
- Review: planner catalogs every instance, writes specific fix per form

**P2-6: JS Event Listener Cleanup**
Scope: 3-4 JS files
- `nav_controller.js` and `dropdown_controller.js` attach `document.addEventListener('click')` without cleanup in `disconnect()` — listeners accumulate on Turbo navigation
- Edit page bottom-button handlers stack on repeated visits
- Win modal inline JS (50-68 lines) should be extracted to Stimulus controller
- Review: planner identifies all leak sites, determines which need Stimulus extraction vs disconnect cleanup

### Tier 3 — Test Coverage (confidence for future changes)

**P2-3: Service Object Test Coverage**
Scope: 3 new spec files, ~200-300 lines
- `GithubChangelogService` (117 lines) — public changelog page, commit filtering, category detection, pagination parsing. All untested.
- `NytPuzzleFetcher` (43 lines) — date parsing fallback, UTF-8 encoding fix, timeout scenarios. Used in active import flow.
- `NytGithubRecorder` (45 lines) — GitHub API recording. Non-critical path but zero coverage.
- Also: `UnpublishedCrossword` model has 100 lines of business logic with no dedicated spec
- Review: planner reads each service, catalogs test cases, flags what needs stubbing

### Tier 4 — Performance (scalability)

**P2-5: NYT Page Pagination**
Scope: controller + view changes, possibly JS
- 705+ puzzles loaded in single query with `.to_a` — grows every day
- Code has `TODO: Add per-tab pagination when puzzle count exceeds ~1500`
- Calendar view uses `.pluck(:id, :created_at)` (lighter), but day tabs load full AR objects
- Review: planner decides server-side pagination vs infinite scroll vs hybrid, scopes to both calendar and day-tab views

**P2-7: Stats Page Performance**
Scope: controller + possibly caching layer
- Multiple `COUNT(*)` queries on every page load (Crossword.count, Solution.where(...).count, User.where(deleted_at: nil).count)
- No index on `users.deleted_at` (used in active member count)
- No caching — every visitor recalculates identical aggregations
- Review: planner decides between fragment caching, counter_cache columns, or background job that writes stats to Redis/cache

---

## Backlog (needs feature work or user decision)

- Clue Suggestions from Phrase DB — infrastructure ready, not planned
- `remotipart` replacement — needs Turbo file upload strategy
- Published column restoration — schema change needed
- Unfriend mechanism — no unfriend feature exists

## Low-Priority Carry-Forward

- Void toggle: new clue numbers render as plain text not `<span class="clue-num">`
- "Pattern Search" tab underlined (link style leak)
- Tool panel tabs overlap footer at scroll bottom
- Title-status spinner GIF vs CSS `.xw-spinner`
- Solve toolbar icons cramped on mobile
