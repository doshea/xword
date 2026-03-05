# Shared Project Board

Cross-persona handoffs. Keep this short — completed items get removed once deployed.

## Builder Pickup Rules

When a Builder picks up a plan:
1. **Timestamp it.** Add `Picked up by Builder at YYYY-MM-DD HH:MM` to the item.
2. **Check for conflicts.** If an item already has a pickup timestamp within the last
   15 minutes, **do not pick it up** — another Builder is already working on it.
3. After 15 minutes with no commit, the pickup expires and the item is available again.

## Pending Deploy

Items built but not yet deployed to production.

- **Create Dashboard polish** — auth guard, `row_top_title`, BEM section headings, empty state,
  ordered queries, new request spec (5 cases). No migration.

## Active / In Progress

### ✅ All recent work deployed (v547–v567)
- Backlog sprint (BEM rename, stats, NYT calendar) — v548
- Vendor Chart.js, CLAUDE.md refresh, session specs — v549
- Solve timer, next puzzle, profile N+1, FriendshipService, error pages — v550
- Visual design review (12 items: empty states, sticky footer, nav labels, error pages, etc.) — v554
- Loading feedback system (4 layers: nav dimming, disable_with, solve toolbar, pattern search) — v555
- Edit save bugs + account settings rebuild + home page polish — v557
- Edit page frontend review (13 items: JS crash fixes, dead code removal, tool panel sizing) — v560
- Pixel-perfect polish: home + solve + edit (save spinners, z-index, a11y, mask-image) — v564
- Edit void toggle crash fix (null guard on next_cell.highlight) — v565
- Edit autosave icon fixes + info pages polish (Contact restructure, CTA buttons, font token) — v566
- Stats page rebuild (6-section community dashboard) — v567

## Planner Work Queue

**Meta-plan:** `claude_personas/plans/planner-meta-plan.md`

16 review items across 3 priority tiers. Planners: pick an item from the meta-plan,
review it, write a plan file, and post a `Planner → Builder` summary here.

**Tier 1 (high value, user-facing):** ~~Create dashboard~~, ~~new puzzle form~~, ~~solution choice
page~~, ~~profile logic audit~~, ~~notifications full page~~, word/clue detail pages

### ~~Planner → Builder: Create Dashboard polish (10 findings)~~ ✅ BUILT
**Plan:** `claude_personas/plans/create-dashboard-review.md`
Built by Builder at 2026-03-04. All 10 findings addressed. 947 specs green.

**Tier 2 (functional):** Search N+1 audit, NYT calendar widget, login/signup, password
reset pages, account settings verification

**Tier 3 (lower priority):** Admin panel, user-made page, team solving UX, test suite
health, backend logic audit

### Planner → Builder: Solution Choice Page polish (8 items)
Picked up by Builder at 2026-03-04 14:00
**Plan:** `claude_personas/plans/solution-choice-review.md`
**Scope:** BEM class rename, a11y fixes, thumbnail overflow, scoped hr rule
**Key changes:**
1. Rename `.metadata`/`.trash-td`/`.not-blue` to BEM classes (update HAML+SCSS+JS)
2. Add `<caption>`, icon `title:` labels, type column `sr-only` header
3. Add `max-width: 100%; height: auto` to global `.xw-thumbnail`
4. Scope bare `hr` rule under new `.xw-solutions-meta` block
5. Optional: add `xw-md-4`/`xw-md-8` for tablet layout
6. Optional: swap `arrow-left` → `chevron-right` icon

### Planner → Builder: Profile page logic/UX review (7 items)
Picked up by Builder at 2026-03-04 15:30
**Plan:** `claude_personas/plans/profile-page-review.md`
**Scope:** Logic fixes, UX improvements, minor code cleanup
**Key changes:**
1. **should-fix:** Hide "In Progress" stat from other users (leaks draft count)
2. **suggestion:** Add turbo_stream to friend accept/reject (currently redirects away from profile)
3. **suggestion:** Add "Edit Profile" link on own profile
4. **nitpick:** Simplify comment includes (remove dead 3rd level), avatar CSS 140→120px,
   display location field, simplify `base_crossword` method
5. **feature gap (separate ticket):** No unfriend mechanism exists anywhere in the app

### Planner → Builder: New Puzzle Form fixes (4 items)
**Plan:** `claude_personas/plans/new-puzzle-form-review.md`
**Summary:** 1 must-fix, 3 should-fix. Small scope — no model changes, no migrations.
1. **must-fix:** Preview void toggle is cosmetic (data never submitted) — remove click
   affordance, make preview read-only, add `aria-hidden`
2. **should-fix:** Replace `spin.min.js` vendor spinner with `.xw-spinner`, delete vendor file
3. **should-fix:** Controller `redirect_to` → `render :new` on validation failure (preserves form state)
4. **should-fix:** Add `disable_with` to submit button
- Files: `new.html.haml`, `_new_form.html.haml`, `new_crossword.scss`, `new.js`,
  `unpublished_crosswords_controller.rb`, delete `spin.min.js`

### Planner → Builder: Notifications full page review (9 items)
**Plan:** `claude_personas/plans/notifications-full-page-review.md`
**Summary:** 4 should-fix, 2 suggestions, 3 nitpicks. System is well-architected (service object,
ActionCable, shared partial, dedup indexes). Issues are UX gaps, not design flaws.
**Key changes:**
1. **should-fix:** No UI to mark individual notifications as read (endpoint exists, nothing calls it).
   Add click-to-navigate + background mark-read on notification rows
2. **should-fix:** "Mark all read" button persists after Turbo Stream (header is outside target).
   Wrap header in replaceable Turbo Frame
3. **should-fix:** Bell button missing `aria-expanded`/`aria-haspopup` (hamburger has it, bell doesn't)
4. **should-fix:** Deleted actor causes crash — add `dependent: :destroy` on `triggered_notifications`
5. Nitpicks: missing punctuation, mobile unread bg, puzzle_invite guard
- Files: `_notification.html.haml`, `index.html.haml`, `_nav.html.haml`,
  `notification_dropdown_controller.js`, `mark_all_read.turbo_stream.erb`, `user.rb`

### Planner → Builder: Changelog page (new feature)
**Plan:** `claude_personas/plans/changelog-page.md`
**Scope:** Public `/changelog` page showing commit history as a timeline
**Key changes:**
1. New `GitHubChangelogService` — HTTParty fetch from GitHub API, 1hr cache per page
2. New `PagesController#changelog` action with pagination
3. New `changelog.html.haml` — timeline grouped by date, category badges, SHA links
4. New `changelog.scss` — BEM styles (`.xw-changelog`)
5. Route: `get '/changelog' => 'pages#changelog'`
6. Footer: add "Changelog" link alongside About/FAQ/Contact/Stats
7. Request spec with stubbed GitHub API

### Low-priority carry-forward (from previous reviews):
- After void toggle, new clue numbers render as plain text not `<span class="clue-num">`
- "Pattern Search" tab button text underlined (link default style leak)
- Tool panel tabs overlap footer when scrolled to bottom
- Title-status spinner uses GIF while save button uses CSS `.xw-spinner`
- Solve page toolbar icons cramped on mobile (minor)

## Backlog

### Clue Suggestions from Phrase DB
Creator feature: suggest clues during puzzle editing based on 53K existing phrases. Query by
word content + text prefix. Infrastructure ready (Phrase model, Word model, pg_search).
Not yet planned in detail — next after timer/next-puzzle ships.
