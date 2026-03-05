# Shared Project Board

## Builder Rules

1. **Timestamp** your pickup: `Picked up by Builder at YYYY-MM-DD HH:MM`
2. If timestamped within 15 min, skip it — another Builder has it
3. After building: move to "Pending Deploy" with commit hash

## Pending Deploy

**P2-5: NYT Page Lazy Tab Loading** — Ready to commit. Lazy-loads day-of-week tabs: only Monday tab renders on initial load, other 6 tabs fetch via `GET /nytimes/day/:wday` on click. Controller refactored to use `@wday_counts` (1 GROUP BY query) + `nytimes_puzzles_for_wday` helper. New `_nyt_day_content` partial. TabsController enhanced with generic `data-lazy-src` fetch (opt-in, no impact on other tab instances). 6 new request specs (19 total NYT specs). No migration. 5 files changed + 1 new partial.

**P2-4: API Cleanup** — Planner reviewed ✅ 1 should-fix. Deleted `Api::UsersController`, `Api::CrosswordsController`, `nyt_source` route. Moved `friends` action to `ApiController`. Deleted `format_for_api` from Crossword + Comment models. Updated `_team.html.haml` route helper. Rewrote API specs (4 examples). No migration. 8 files changed.
- **should-fix**: `ApiController#friends` `.select` doesn't include `:deleted_at` but `display_name` calls `deleted?` → `deleted_at.present?`. Will raise `MissingAttributeError` if a deleted user has a friendship. Fix: add `:deleted_at` to select list (pre-existing bug, easy fix during relocation).

**P2-6: JS Event Listener Cleanup** — Planner reviewed ✅ Clean. Moved `document.onkeydown`/`onkeypress` from parse-time global assignment into `turbo:load` handler with cleanup on non-crossword pages. Fixes keyboard scrolling suppression site-wide after visiting solve/edit. 1 file changed. No migration, no spec changes.

**P2-1: DB Constraints Migration** — Planner reviewed ✅ Clean. Migration with pre-flight dupe checks, ctid dedup, 6 unique indexes, cell_edits drop, partial solution index. RecordNotUnique rescues in CrosswordsController + Crossword model. All follow established patterns.

## Builder In Progress

(none)

## Planner → Builder Queue

Pick in order. **Read the plan file for full details** — don't rely on summaries here.

~~**P2-1: Database Constraints Migration**~~ ✅ Built. Pending commit.

~~**P2-2: Form Accessibility Audit**~~ ✅ Built. Pending commit.

~~**P2-5: NYT Page Lazy Tab Loading**~~ ✅ Built. Pending commit.

~~**P2-4: API Cleanup**~~ ✅ Built. Pending commit.

~~**P2-3: Service Object Test Coverage**~~ ✅ Built. Pending commit.

~~**P2-6: JS Event Listener Cleanup**~~ ✅ Built. Pending commit.

## Planner Work Queue

Full queue: `claude_personas/plans/planner-meta-plan.md`

| Phase | Status | Items |
|-------|--------|-------|
| 1 | ✅ Done | 16 reviews + changelog, deployed v548–v574 |
| 2 | ✅ Done | 7/7 reviewed: DB constraints ✅, service specs ✅, API security ✅, NYT pagination ✅, JS cleanup ✅, a11y ✅ (built), stats perf ✅ (no build needed) |

## Low-Priority Carry-Forward

- Void toggle clue numbers as plain text (not `<span class="clue-num">`)
- "Pattern Search" tab underlined (link style leak)
- Tool panel tabs overlap footer
- Title-status spinner GIF vs CSS `.xw-spinner`
- Solve toolbar icons cramped on mobile

## Backlog

- **Clue Suggestions from Phrase DB** — infrastructure ready, not planned
- **Unfriend mechanism** — no unfriend feature exists anywhere

## Deploy Log

Remove entries older than 2 weeks.

v548–v550: BEM, stats, NYT calendar, Chart.js, solve timer, profile N+1, error pages
v554–v557: Visual review, loading feedback, edit save bugs, account settings, home polish
v560–v567: Edit frontend, pixel-perfect, void toggle fix, autosave icons, info pages, stats rebuild
v569: Solution choice, create dashboard, profile, changelog
v570: Word/clue detail, notifications polish, new puzzle form
v571: Search page fixes (blank guard, limits, N+1)
v572: Login/signup polish (Turbo Stream fix, a11y, redirects, dead CSS/specs)
v573: Changelog polish (CSS loading fix, prefix stripping, noise filtering, a11y)
v574: Review items 5–12 (passwords, NYT, team solving, test health, backend audit + unique index migration)
v576: Form a11y audit, 72 service/model specs, tab controller fix (aria-controls)
