# Shared Project Board

## Builder Rules

1. **Timestamp** your pickup: `Picked up by Builder at YYYY-MM-DD HH:MM`
2. If timestamped within 15 min, skip it — another Builder has it
3. After building: move to "Pending Deploy" with commit hash

## Builder In Progress

(none)

## Pending Deploy

(empty — all clear)

## Planner → Builder Queue

- **Empty State Delight** — Home page welcome hub + create dashboard polish. Plan: `plan.md`. 5 files, no migration, no JS. Low risk, all additive.


## Planner Work Queue

Full queue: `claude_personas/plans/planner-meta-plan.md`

| Phase | Status | Items |
|-------|--------|-------|
| 1 | ✅ Done | 16 reviews + changelog, deployed v548–v574 |
| 2 | ✅ Done | 7 reviewed, 6 built, deployed v576–v578. Stats perf = no build needed. |
| 3 | ✅ Done | 8/8 built. Deploys 1+2 shipped (v579, va1c069e). Deploy 3+4 (P3-E + P3-H) shipped v580. |
| 4 | ✅ Done | 5/5 built and deployed (v581). |

## Low-Priority Carry-Forward

(cleared — all items deployed through v582)

## Backlog

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
v579: Composite indexes (cells, crosswords), random puzzle offset fix, stale TODO cleanup
v580: Loading spinners (home/NYT/LoadingController), solve home button, mobile comment Send button
v581: Phase 4 — mini-manuals, clue suggestions, unfriend, remotipart removal
v582: Solve mini-manual polish (7→4 sections, arrow key diagram), persona terminal text color fix
v586: Rebus cell support infrastructure (rebus_map JSONB on crosswords+solutions, full-stack wiring)
v586–v596: Rebus class fix, admin form styling, team solve fixes, auth hardening, cell flash tuning
v597: Notification bell refinements (hidden for zero-history, pulse reserved for ActionCable)
