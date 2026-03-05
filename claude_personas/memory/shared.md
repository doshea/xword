# Shared Project Board

## Builder Rules

1. **Timestamp** your pickup: `Picked up by Builder at YYYY-MM-DD HH:MM`
2. If timestamped within 15 min, skip it — another Builder has it
3. After building: move to "Pending Deploy" with commit hash

## Pending Deploy

**P2-2: Form Accessibility Audit** — Ready to commit. 17 a11y fixes: 7 aria-labels on inputs, 8 anchor→button conversions (+ CSS resets), 2 tab link→button conversions. Deleted dead reply edit pencil. Updated 1 spec. No migration. 14 files changed.

## Builder In Progress

(none)

## Planner → Builder Queue

Pick in order. **Read the plan file for full details** — don't rely on summaries here.

~~**P2-1: Database Constraints Migration**~~ ✅ Built. Pending commit.

**P2-2: Form Accessibility Audit** → `claude_personas/plans/form-accessibility-audit.md` — Picked up by Builder at 2026-03-05 14:30
17 issues: 7 must-fix (unlabeled inputs), 8 should-fix (a→button), 2 suggestion (tab links).
3 batches, ~1hr total. No migrations, no JS changes, no new specs needed.
`<main>` landmark concern was false alarm — all pages inherit from application layout.

~~**P2-3: Service Object Test Coverage**~~ ✅ Built. Ready to commit. 4 new spec files (72 examples): NytPuzzleFetcher (11), NytGithubRecorder (7), GithubChangelogService (35), UnpublishedCrossword (19). `letters_to_clue_numbers` verified working correctly — TODO comment is stale. No migration, no source changes.

## Planner Work Queue

Full queue: `claude_personas/plans/planner-meta-plan.md`

| Phase | Status | Items |
|-------|--------|-------|
| 1 | ✅ Done | 16 reviews + changelog, deployed v548–v574 |
| 2 | 🔄 In progress | 2/7 reviewed: DB constraints ✅, service specs ✅ — a11y, API security, NYT pagination, JS cleanup, stats perf remaining |

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
