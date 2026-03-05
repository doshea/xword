# Planner Work Queue

## Workflow

1. Pick an unreviewed item below
2. Write findings to `claude_personas/plans/<slug>.md` (severity-rated)
3. Update the item's status in this file
4. Add a short `Planner → Builder` entry on `shared.md` pointing to the plan file

---

## Status

| # | Item | Status | Plan |
|---|------|--------|------|
| 1 | Create Dashboard | ✅ Deployed v569 | `create-dashboard-review.md` |
| 2 | New Puzzle Form | 📋 Awaiting Builder | `new-puzzle-form-review.md` |
| 3 | Solution Choice Page | ✅ Deployed v569 | `solution-choice-review.md` |
| 4 | Profile Page | ✅ Deployed v569 | `profile-page-review.md` |
| 5 | Notifications Full Page | 🏗️ Builder in progress | `notifications-full-page-review.md` |
| 6 | Word/Clue Detail Pages | ✅ Built, pending deploy | `word-clue-detail-review.md` |
| 7 | Search Page | 📋 Awaiting Builder | `search-page-review.md` |
| 8 | NYT Page / Calendar | 📋 Awaiting Builder | `nyt-calendar-review.md` |
| 9 | Login / Signup | ✅ Reviewed | `login-signup-review.md` |
| 10 | Forgot / Reset Password | 📋 Awaiting Builder | `forgot-reset-password-review.md` |
| 11 | Account Settings | ✅ Reviewed | `account-settings-review.md` |
| 12 | Admin Panel | ⬜ Unreviewed | — |
| 13 | User-Made Puzzles Page | ⬜ Unreviewed | — |
| 14 | Team Solving UX | ⬜ Unreviewed | — |
| 15 | Test Suite Health | ⬜ Unreviewed | — |
| 16 | Backend Logic Audit | ⬜ Unreviewed | — |
| — | Changelog (new feature) | 📋 Awaiting Builder | `changelog-page.md` |

Previously deployed (no plan needed): home, solve, edit, welcome, nav, footer,
notification dropdown, error pages, loading feedback, stats, info pages, edit autosave.

---

## Unreviewed Items

### ~~8. NYT Puzzles Page~~ — ✅ Reviewed
2 should-fix (705 puzzles loaded at once, no ARIA tab roles), 1 suggestion (calendar not centered), 3 nitpick (IIFE wrap, hardcoded gap, innerHTML concatenation)

### ~~9. Login/Signup Page~~ — ✅ Reviewed
1 must-fix (turbo stream destroys #password-errors target), 3 should-fix (a11y labels, redirect lost on signup, /login accessible when logged in), 4 suggestions (title mismatch, missing title, dead CSS, duplicate specs)

### ~~10. Forgot/Reset Password~~ — ✅ Reviewed
1 must-fix (turbo stream destroys own target), 4 should-fix (a11y labels, autocomplete, title), 4 suggestions (dead CSS, dead markup, layout inconsistency, vestigial DB columns)

### 11. Account Settings (`/users/account`)
**Files:** `users/account.html.haml`, `users/partials/_account_form.html.haml`, `account.scss.erb`, `account.js`
**Check:** Rebuilt v557 — quick verification. Remotipart upload, password change flow, delete account

### 12. Admin Panel
**Files:** `admin/*.html.haml`, `admin.scss` (315 lines, tokenized), layout partials
**Check:** Nav, tables, edit forms, email tester, cloning tank, manual NYT import. Low priority (owner-only).

### 13. User-Made Puzzles (`/user_made`)
**Files:** `pages/user_made.html.haml` (13 lines)
**Check:** Visual parity with NYT page, ordering, pagination (none currently)

### 14. Team Solving UX
**Files:** `crosswords/partials/_team.html.haml`, `team_funcs.js.erb` (328 lines), `solutions_controller.rb`
**Check:** Create/join flow, real-time conflicts, chat, disconnect recovery, leave-team behavior

### 15. Test Suite Health
**Files:** All `spec/` files
**Check:** Controller→request spec migration list, `live_search` flaky test root cause,
`should`→`expect()` in FriendRequest, feature spec coverage gaps

### 16. Backend Logic Audit
**Files:** All controllers + models
**Check:** Auth gaps, mass assignment, N+1 on home/nytimes/user_made, unused Publishable scopes

---

## Backlog (needs feature work first)

- Clue Suggestions from Phrase DB — infrastructure ready, not planned
- `remotipart` replacement — needs Turbo file upload
- Published column restoration — schema change needed
- Unfriend mechanism — no unfriend feature exists

## Low-Priority Carry-Forward

- Void toggle: new clue numbers render as plain text not `<span class="clue-num">`
- "Pattern Search" tab underlined (link style leak)
- Tool panel tabs overlap footer at scroll bottom
- Title-status spinner GIF vs CSS `.xw-spinner`
- Solve toolbar icons cramped on mobile
