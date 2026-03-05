# Shared Project Board

## Builder Rules

1. **Timestamp** your pickup: `Picked up by Builder at YYYY-MM-DD HH:MM`
2. If timestamped within 15 min, skip it — another Builder has it
3. After building: move to "Pending Deploy" with commit hash

## Pending Deploy

**Carry-Forward Bug Fixes** — 5 low-priority polish fixes. No migration. 5 files changed + 1 GIF deleted.
- Void toggle: `number_clues()` now creates missing span, clears stale numbers
- Pattern Search tab: `text-decoration: none` on `.bottom-button`
- Tool panel/footer overlap: `margin-bottom: 2.5em` on `#advanced`
- GIF spinner → CSS `.xw-spinner` (deleted `spinner_small.gif`, updated JS + CSS + HAML)
- Solve toolbar mobile: `gap: var(--space-3)` at `< 640px`

## Builder In Progress

(none)

## Planner → Builder Queue

Pick in order. **Read the plan file for full details** — don't rely on summaries here.

All Phase 2 items built and committed:
- ~~P2-1~~ ✅ `516c906` — DB constraints, RecordNotUnique rescues
- ~~P2-2~~ ✅ `01e8ea0` — Form accessibility audit
- ~~P2-3~~ ✅ `a3f5f1b` — Service object test coverage (72 examples)
- ~~P2-4~~ ✅ `516c906` — API cleanup (deleted 2 controllers, moved friends)
- ~~P2-5~~ ✅ `3508192` — NYT lazy tab loading
- ~~P2-6~~ ✅ `516c906` — JS keyboard listener fix

## Planner Work Queue

Full queue: `claude_personas/plans/planner-meta-plan.md`

| Phase | Status | Items |
|-------|--------|-------|
| 1 | ✅ Done | 16 reviews + changelog, deployed v548–v574 |
| 2 | ✅ Done | 7/7 reviewed, 6/6 built & committed. Stats perf = no build needed. |

## Low-Priority Carry-Forward

(cleared — all 5 items built, pending deploy)

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
v577: NYT lazy tabs, DB constraints migration (7 indexes), API security (deleted PII leak), JS keyboard fix
