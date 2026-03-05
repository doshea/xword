# Shared Project Board

## Builder Rules

1. **Timestamp** your pickup: `Picked up by Builder at YYYY-MM-DD HH:MM`
2. If timestamped within 15 min, skip it — another Builder has it
3. After building: move to "Pending Deploy" with commit hash

## Pending Deploy

(none)

## Builder In Progress

(none)

## Planner → Builder Queue

Pick in order. **Read the plan file for full details** — don't rely on summaries here.

| # | Item | Scope | Plan |
|---|------|-------|------|
| ~~3~~ | ~~Changelog UX Polish~~ | ~~2 must-fix, 2 should-fix, 2 suggestions~~ | ~~Done~~ |
| ~~4~~ | ~~Login / Signup~~ | ~~1 must-fix, 3 should-fix, 4 suggestions~~ | ~~Done~~ |
| ~~5~~ | ~~Forgot/Reset Password~~ | ~~1 must-fix, 4 should-fix~~ | ~~Done~~ |
| ~~6~~ | ~~NYT Page / Calendar~~ | ~~2 should-fix, 1 suggestion, 3 nitpick~~ | ~~Done~~ |
| ~~7~~ | ~~Account Settings~~ | ~~3 should-fix, 2 suggestions (bundled with #5)~~ | ~~Done~~ |
| ~~8~~ | ~~User-Made Puzzles~~ | ~~1 should-fix, 2 suggestions~~ | ~~Done~~ |
| ~~9~~ | ~~Admin Panel~~ | ~~2 should-fix, 3 suggestions~~ | ~~Done (all findings pre-implemented)~~ |
| ~~10~~ | ~~Team Solving UX~~ | ~~4 should-fix, 2 suggestions~~ | ~~Done (most pre-implemented; added SolutionPartnering unique index)~~ |
| ~~11~~ | ~~Test Suite Health~~ | ~~1 must-fix, 1 should-fix, 2 suggestions~~ | ~~Done (flaky fix + 107 should→expect)~~ |
| ~~12~~ | ~~Backend Logic Audit~~ | ~~4 should-fix, 4 suggestions~~ | ~~Done~~ |

## Planner Work Queue

Full queue with context: `claude_personas/plans/planner-meta-plan.md`

| Tier | Status | Remaining |
|------|--------|-----------|
| 1 | ✅ Done | — |
| 2 | ✅ Done | — |
| 3 | ✅ Done | — |

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
