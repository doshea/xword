# Planner Memory

## Architecture Decisions (Reference)

### CrosswordPublisher pattern (2026-03-03)
- Class-method-based service (`CrosswordPublisher.publish(ucw)`) following `NytPuzzleImporter` pattern
- Custom `BlankCellsError` for validation failures — controller maps exceptions to redirects
- Team broadcast extraction skipped — SolutionsController's private method is already clean (6 lines)

### Default scope removal rationale (2026-03-04)
- `default_scope` ordering is prepended; subsequent `.order()` calls APPEND (not replace). Only `.reorder()` replaces.
- 3 production bugs fixed: random puzzle always newest, search relevance suppressed, admin sort ignored.

## Completed Work (Summary)

All items below have been designed, built, and deployed. Kept for reference only.

| Date | Design/Review | Commit(s) | Deploy |
|------|--------------|-----------|--------|
| 03-03 | CrosswordPublisher extraction | (earlier) | pre-v547 |
| 03-03 | Code review: publish flow + dead code | (earlier) | pre-v547 |
| 03-04 | Default scope removal (3 prod bugs) | `3091b3a` | pre-v547 |
| 03-04 | Clue UTF-8 double-encoding fix | `1c6aff5` | pre-v547 |
| 03-04 | Welcome page rebuild | `9ff2f66` | pre-v547 |
| 03-04 | Footer colophon redesign | `0c8a75d` | pre-v547 |
| 03-04 | Load-more pagination (homepage) | `5dc0897` | pre-v547 |
| 03-04 | Reveal hints v1 + v2 (letter/word + black tabs) | `13da633`, `414f0a9` | pre-v547 |
| 03-04 | Admin test tools (fake win + reveal/clear/flash) | `927cb43` | pre-v547 |
| 03-04 | Cell check flash cascade | `2b5612c` | pre-v547 |
| 03-04 | Solve-mode bug fixes (row height + focus jump) | `3b7ee04` | pre-v547 |
| 03-04 | Blurry puzzle preview thumbnails | (part of visual polish) | v554 |
| 03-04 | Notification system v2/v3 | `8322603` | pre-v547 |
| 03-04 | Notification dropdown (DotA2-style) | `d70a407` | pre-v547 |
| 03-04 | Puzzle card BEM rename | `1c657c6` | v548 |
| 03-04 | Stats page modernization (Chart.js v4) | `9487159`, `7f225ce` | v548/v549 |
| 03-04 | NYT day-of-week tabs + calendar | `ea7a63c`, `e721c27` | v548 |
| 03-04 | Solve timer + next puzzle on win | `c710d75`, `4151063` | v550 |
| 03-04 | Profile N+1 + FriendshipService | `6d2bce7` | v550 |
| 03-04 | Full screenshot design review (22 pages) | `dd1c98d` | v554 |
| 03-04 | Loading feedback system (4 layers) | `4ac4d7b` | v555 |
| 03-04 | Edit save bugs (void corruption + preventDefault) | `7c8c26b`, `908c4f5` | v557 |
| 03-05 | Account settings rebuild | `908c4f5` | v557 |
| 03-04 | Homepage pixel-perfect review | `6748a33`, `2a32c0c` | v557/v564 |
| 03-05 | Edit page frontend review (13 items) | `a3bed4d` | v560 |
| 03-04 | Pixel-perfect solve page review | `2a32c0c` | v564 |
| 03-05 | Edit page pixel-perfect review | `2a32c0c` | v564 |
| 03-04 | Edit save spinners (3 iterations) | `8791c6c`→`928b0b1`→`34d49db` | v564 |
| 03-04 | Test suite performance audit | Closed — already optimized | N/A |
| 03-04 | Playwright MCP setup | Tool config, not code | N/A |

## Meta-Plan (2026-03-04)

Created `claude_personas/plans/planner-meta-plan.md` — a work queue for planners.
Full codebase audit: 26 controllers, 101 view templates, 23 JS files, 19 CSS files,
17 models/concerns, 6 services, 89 spec files.

**16 review items** identified across 3 priority tiers:
- **Tier 1 (6 items):** Create dashboard, new puzzle form, solution choice page,
  profile logic audit, notifications full page, word/clue detail pages
- **Tier 2 (5 items):** Search N+1 audit, NYT page/calendar widget, login/signup,
  forgot/reset password, account settings verification
- **Tier 3 (5 items):** Admin panel, user-made page, team solving UX, test suite health,
  backend logic audit

### New Puzzle Form review (2026-03-04)
- Preview void toggling is cosmetic — never serialized or submitted. Recommend removing
  the interaction (Option B) rather than wiring it up (Option A). Edit page has full void
  tooling already.
- `spin.min.js` is the only vendor spinner library, used on this one page. Replace with
  `.xw-spinner` (pure CSS, 12 lines, already in `global.scss.erb`).
- Controller uses `redirect_to` on validation failure — loses all form state. Standard
  Rails `render :new` preserves the `@ucw` object with errors.
- Form styling is excellent — fully tokenized, BEM naming, responsive. No design issues.

### Notifications full page review (2026-03-04)
- System is very well-built: service object, ActionCable, shared partial, dedup indexes,
  lazy-loading dropdown. CSS fully tokenized. Code quality is high.
- The `mark_read` controller action + Turbo Stream exists but nothing in the UI calls it.
  Friend requests have Accept/Decline but those don't mark the notification as read either.
- `mark_all_read` on full page uses `button_to` (Turbo form) but the Turbo Stream only
  replaces `#notifications-list` — the button is in the header, outside the target.
  Dropdown handles this correctly via JS.
- `actor_id` has no foreign key constraint and no `dependent:` from the actor side of User.
  If an actor user is deleted, `notification.actor` → nil → crash in partial.
- Full page and dropdown share the same `_notification.html.haml` partial. Dropdown CSS
  overrides make it compact (smaller avatar, no border-radius, bottom borders only).
- `.recent` scope hard-caps at 50 — older notifications unreachable. Acceptable for now.
- Notification bell button has no ARIA attributes (hamburger button does).
- Grade: A- — architecture is clean, issues are polish/UX gaps not structural problems.

## Active Items

### Planner → Builder: Changelog page (new feature)
- Plan at `claude_personas/plans/changelog-page.md`
- Public `/changelog` page showing git commit history as a timeline
- GitHub REST API + Rails.cache (1hr TTL), not DB
- `GitHubChangelogService` + PagesController#changelog + BEM timeline view
- WillPaginate::Collection wrapping for pagination, footer link, request spec

### Word/Clue Detail Pages review (2026-03-04)
- Plan at `claude_personas/plans/word-clue-detail-review.md`
- Grade: C — functional but bare-bones, never received design polish pass
- 5 should-fix: N+1 on crossword.user (both controllers), Ruby sort_by → SQL order,
  clue page missing word display, word page missing letter count, clue page missing difficulty
- Both pages structurally sound: orphan guard, RecordNotFound rescue, auth on update
- `crosswords_by_title` uses `.or()` SQL (good), but neither controller adds `.includes(:user)` —
  every other controller in the app does this for crossword_tab rendering
- Note: `@count` fires 2 COUNT queries but is intentionally different from `@crosswords.length`
  (appearances vs unique puzzles). The distinction is meaningful.
- Tier 1 review queue is now **complete** (all 6 items reviewed)

### On shared.md — awaiting Builder pickup:

**Notifications full page review (9 items)**
- Plan at `claude_personas/plans/notifications-full-page-review.md`
- Grade: A- — architecture is excellent, 4 should-fix UX/a11y gaps

**New Puzzle Form fixes (4 items)**
- Plan at `claude_personas/plans/new-puzzle-form-review.md`
- Grade: B — form styling is solid (tokens, BEM, responsive), but void toggle is misleading
  and spinner is the last vendor library holdout. Quick wins.

**Solution Choice Page polish (8 items)**
- Plan at `claude_personas/plans/solution-choice-review.md`
- Grade: B+ — fully tokenized SCSS, good test coverage, needs BEM rename + a11y + thumbnail fix
- 4 should-fix items, 2 optional improvements

**Create Dashboard polish (10 findings)**
- Plan at `claude_personas/plans/create-dashboard-review.md`
- Grade: C+ — puzzle cards use shared BEM components (good), but page chrome is unstyled
- 4 should-fix: unstyled headings, no empty state, inline logged-out, no query ordering
- Key decision: use `ensure_logged_in` (recommended) vs keep logged-out branch with empty-state

**Edit page autosave icon fixes (3 issues)** — built (132be74), pending deploy

**Stats page rebuild (6-section community dashboard)**
- Plan at `claude_personas/plans/stats-page-rebuild.md`

**Info pages polish (About, FAQ, Contact)**
- Review at `claude_personas/plans/info-pages-review.md`

**Profile page logic/UX review (7 items)**
- Plan at `claude_personas/plans/profile-page-review.md`
- Grade: A- — well-tested, polished CSS, N+1 already mitigated. One should-fix (draft count leak),
  two UX suggestions (turbo accept/reject, edit profile link), four nitpicks
- Notable: comment nesting is capped at 2 levels by controller, so `base_crossword` loop
  and 3-level includes are over-engineered but functionally correct
- No unfriend feature exists anywhere — flagged as separate ticket

### All other review work → see `claude_personas/plans/planner-meta-plan.md`

## Backlog

### Clue Suggestions from Phrase DB
Creator feature: suggest clues during editing based on 53K existing phrases. Query by word content + text prefix. Infrastructure ready (Phrase model, Word model, pg_search). Not yet planned in detail.

## Open Questions

- 4 unused Publishable scopes (`standard`, `nonstandard`, `solo`, `teamed`) — prune when convenient
- FriendRequest model spec uses `should` syntax — migrate to `expect()` when touching that file
