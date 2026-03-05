# Shared Project Board

## Builder Rules

1. **Timestamp** your pickup: `Picked up by Builder at YYYY-MM-DD HH:MM`
2. If timestamped within 15 min, skip it — another Builder has it
3. After building: move to "Pending Deploy" with commit hash

## Pending Deploy

**Deploy 1 — Quick wins (P3-D partial + P3-B + P3-G + P3-F)** — awaiting commit
- P3-D: Removed stale TODO in home.html.haml. **Planner correction**: `include TimeHelper` is NOT dead (module in `lib/custom_funcs.rb`, used in win modal), `letters_to_clue_numbers` is NOT dead (called by `UnpublishedCrosswordsController#edit`, has 3 specs).
- P3-B + P3-G: Added 2 composite indexes via concurrent migration (`cells(crossword_id, row, col)`, `crosswords(user_id, created_at DESC)`)
- P3-F: Replaced `ORDER BY RANDOM()` with `offset(rand(count))` in 3 locations (pages_controller, crosswords_controller, user.rb)
- 1039 examples, 0 failures

## Builder In Progress

(none)

## Planner → Builder Queue

Pick in order. **Read the plan file for full details** — don't rely on summaries here.

### Awaiting Planner Review (Deploy 2–4)

| Item | Status | Notes |
|------|--------|-------|
| P3-A: Solve Confidence | ✅ Ready for Builder | Plan: `claude_personas/plans/solve-confidence.md` |
| P3-C: Design Token Completion | ✅ Ready for Builder | Plan: `claude_personas/plans/design-token-completion.md` |
| P3-E: Loading State Spinners | Queued | Mechanical — may skip review |
| P3-H: Solve Page Navigation | Queued | After P3-A |

## Planner Work Queue

Full queue: `claude_personas/plans/planner-meta-plan.md`

| Phase | Status | Items |
|-------|--------|-------|
| 1 | ✅ Done | 16 reviews + changelog, deployed v548–v574 |
| 2 | ✅ Done | 7 reviewed, 6 built, deployed v576–v578. Stats perf = no build needed. |
| 3 | 🔄 Active | 8 items (rewritten): solve confidence, 2 indexes, tokens, dead code, spinners, random fix, nav polish |

## Low-Priority Carry-Forward

(cleared — all items deployed through v578)

## Backlog

- **Clue Suggestions from Phrase DB** — infrastructure ready, not planned
- **Unfriend mechanism** — no unfriend feature exists anywhere
- **Admin Form Styling** — 6 admin views, single-user audience, zero user impact
- **Inline Form Validation** — CSS classes exist but unused; feature not fix; defer until drop-off observed
- **Review Checklist Template** — create when team grows

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
v577: NYT lazy tabs, DB constraints migration (7 indexes), API security (deleted PII leak), JS keyboard fix
v578: 5 polish fixes (clue numbers, tab underline, footer overlap, GIF→CSS spinner, mobile toolbar)
