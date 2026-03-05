# Shared Project Board

## Builder Rules

1. **Timestamp** your pickup: `Picked up by Builder at YYYY-MM-DD HH:MM`
2. If timestamped within 15 min, skip it — another Builder has it
3. After building: move to "Pending Deploy" with commit hash

## Pending Deploy

- **Word/Clue Detail Pages** — N+1 fix, page titles, SQL ordering, word length, difficulty indicators, spec syntax. 966 specs green.
- **Notifications Full Page** — click-to-mark-read, mark-all-read Turbo Stream fix, bell ARIA, deleted actor guard, punctuation, mobile dropdown unread bg, empty state icon. 8 new specs. No migration. 974 specs green.
- **New Puzzle Form** — validation re-render (was redirect), disable_with on submit, void toggle removed from preview (read-only), spin.min.js deleted + CSS .xw-spinner overlay, error display in form, aria-hidden on preview, JS to content_for :head. 5 new request specs. No migration. 979 specs green.

## Builder In Progress

(none)

## Planner → Builder Queue

Pick in order. **Read the plan file for full details** — don't rely on summaries here.

| # | Item | Scope | Plan |
|---|------|-------|------|
| 2 | Search Page | 3 should-fix (N+1, limits, blank query) | `plans/search-page-review.md` |
| 3 | Changelog | New feature (service + page + specs) | `plans/changelog-page.md` |
| 4 | Login / Signup | 1 must-fix, 3 should-fix, 4 suggestions | `plans/login-signup-review.md` |
| 5 | Forgot/Reset Password | 1 must-fix, 4 should-fix | `plans/forgot-reset-password-review.md` |
| 6 | NYT Page / Calendar | 2 should-fix, 1 suggestion, 3 nitpick | `plans/nyt-calendar-review.md` |
| 7 | Account Settings | 3 should-fix, 2 suggestions (bundle with #5) | `plans/account-settings-review.md` |

## Planner Work Queue

Full queue with context: `claude_personas/plans/planner-meta-plan.md`

| Tier | Status | Remaining |
|------|--------|-----------|
| 1 | ✅ Done | — |
| 2 | ✅ Done | — |
| 3 | 0/5 | Admin, user-made, team solving, test suite, backend audit |

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
