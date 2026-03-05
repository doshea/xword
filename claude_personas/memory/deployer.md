# Deployer Memory

## Deploy History

### v579 — 2026-03-05
**Commit:** `924e958`
**Changes:** Composite indexes, random puzzle offset fix, stale TODO cleanup:
- 2 composite indexes: `cells(crossword_id, row, col)`, `crosswords(user_id, created_at DESC)`
- `ORDER BY RANDOM()` → `offset(rand(count))` in 3 locations (pages_controller, crosswords_controller, user.rb)
- Stale TODO removed from home.html.haml
**Migration:** `20260305120001_add_composite_indexes_to_cells_and_crosswords` — 2 concurrent indexes (2.23s total)
**Rollback:** `heroku run rake db:migrate:down VERSION=20260305120001` + `git revert 924e958`
**Post-deploy:** Release v579. Migration completed in release phase (2.23s). Puma up ~3s, 2 workers booted. Homepage 302 (redirect to www), /random 302 (redirect to puzzle). Redis SSL warning on changelog (pre-existing, cosmetic). No app errors.

### v578 — 2026-03-05
**Commits:** `b0b3b62`, `09c9a9f`
**Changes:** Low-priority polish + gitignore housekeeping:
- `.gitignore`: `*.png` (preserving app asset images)
- Void toggle: `number_clues()` creates missing span, clears stale numbers
- Pattern Search tab: `text-decoration: none` on `.bottom-button`
- Tool panel/footer overlap: `margin-bottom: 2.5em` on `#advanced`
- GIF spinner → CSS `.xw-spinner` (deleted `spinner_small.gif`)
- Solve toolbar mobile: `gap: var(--space-3)` at `< 640px`
**Migration:** None
**Rollback:** `git revert 09c9a9f b0b3b62` (pure CSS/JS/HAML/.gitignore, instant)
**Post-deploy:** Release v578. Release phase exit 0 (no-op migration). Puma up ~3s. First request 200 (5.2s cold AR cache). Build succeeded. No errors.

### v577 — 2026-03-05
**Commits:** `3508192`, `516c906`
**Changes:** NYT lazy tabs + Phase 2 cleanup (API security, DB constraints, JS keyboard):
- NYT page: lazy-load day-of-week tabs (only Monday renders initially, others fetched on click). New `/nytimes/day/:wday` route + `_nyt_day_content` partial. 6 new request specs.
- P2-1 DB constraints: `cell_edits` table dropped, ctid dedup on friendships/friend_requests/solutions, 6 unique indexes (users.email, users.username, friendships, friend_requests, words.content, solutions partial). `RecordNotUnique` rescues added.
- P2-4 API security: `Api::UsersController` + `Api::CrosswordsController` deleted (unauthenticated PII leak). `/api/nyt_source` route removed. `friends` moved to `ApiController`. `format_for_api` deleted from Crossword + Comment. `deleted_at` added to select list (MissingAttributeError fix).
- P2-6 JS keyboard: `onkeydown`/`onkeypress` moved into `turbo:load` handler with cleanup. Fixes arrow/space scrolling suppression site-wide.
**Migration:** `20260305120000_add_database_constraints` — pre-flight dupe checks, drop cell_edits, ctid dedup, 7 indexes (1.58s total)
**Rollback:** `heroku run rake db:migrate:down VERSION=20260305120000` + `git revert 516c906 3508192`
**Post-deploy:** Migration completed in release phase (1.58s). No duplicate data found. Puma up ~3s, 2 workers. State changed to up. No errors.

### v576 — 2026-03-05
**Commits:** `01e8ea0`, `044678d`, `a3f5f1b`, `d8d48a4`
**Changes:** A11y audit + specs + critical tab fix:
- Form a11y: 7 aria-labels on inputs, 8 `<a>`→`<button>` conversions, home/NYT tab links→buttons, dead reply pencil deleted
- Persona memory + 5 Phase 2 plan docs (no app code)
- 72 new specs: NytPuzzleFetcher, NytGithubRecorder, GithubChangelogService, UnpublishedCrossword
- **Critical fix**: tabs controller used `getAttribute('href')` which returns null on `<button>` — now uses `aria-controls` with `href` fallback. Tab lazy-load support added.
**Migration:** None
**Rollback:** `git revert d8d48a4 a3f5f1b 044678d 01e8ea0` (pure frontend/specs/docs, instant)
**Post-deploy:** Release v576. Release phase exit 0 (no-op migration). Puma up ~3s, 2 workers booted. Build succeeded. No errors.

### v574 — 2026-03-05
**Commit:** `ecaebe9`
**Changes:** Bulk deploy — review items 5–12:
- Forgot/Reset Password (#5): required/maxlength, autocomplete, layout, dead div, 5 specs
- NYT Page (#6): calendar .pluck, ARIA tab roles, centering, IIFE
- Account Settings (#7): verified pre-implemented
- User-Made Puzzles (#8): title, count, 2 specs
- Admin Panel (#9): find_by guard, dead mail field, wine_comment rename
- Team Solving (#10): sendBeacon, Foundation tooltip replaced, invite CSS, anon guards, chat token
- Test Suite Health (#11): flaky fix, 107 should→is_expected.to
- Backend Logic Audit (#12): ensure_admin, dependent: :destroy/:nullify, self-friend guard, Word content validation, 8 unused scopes deleted
**Migration:** `20260305080039_add_unique_index_to_solution_partnerings` — remove 2 single-column indexes, add composite unique + user_id index (0.72s on 39 rows)
**Rollback:** `git revert ecaebe9` + `heroku run rake db:migrate:down VERSION=20260305080039`
**Post-deploy:** Migration ran in release phase (0.72s). Puma up ~4s. First requests slow (cold AR cache, 3-5s) then normalized (1.3s). H27 client interrupts on first burst (impatient browser during cold boot — cosmetic). New asset fingerprints picked up. No app errors.

### v573 — 2026-03-05
**Commit:** `ba0e4f3`
**Changes:** Changelog page polish:
- CSS stylesheet fix (`content_for :head` — was never loading)
- Strip redundant category prefix from messages ("Fix Fix..." → "Edit page...")
- Filter internal commits (memory/merge/CLAUDE.md)
- Better categorization of test commits
- Mobile stacking order fix
- `<button disabled>` for pagination boundaries
**Migration:** None
**Rollback:** `git revert ba0e4f3` (pure service/view/CSS/spec, instant)
**Post-deploy:** Clean. Release phase exit 0 (no-op). Puma up ~3s. New `changelog` CSS fingerprint compiled. No errors.

### v572 — 2026-03-05
**Commit:** `c907bff`
**Changes:** Login/Signup polish:
- Turbo Stream `#password-errors` target ID preserved after first error (was destroyed on replacement)
- A11y labels on reset password fields
- Redirect param carried through signup flow
- Logged-in users redirected away from `/login` and `/users/new`
- Title/heading unified to "Log In", missing reset password `<title>` added
- Dead `forgot_password.scss` deleted
- Duplicate legacy controller specs removed (sessions, users) — request specs cover all scenarios
**Migration:** None
**Rollback:** `git revert c907bff`
**Post-deploy:** Clean. Release phase exit 0 (no-op migration). Puma up ~3s. No errors.

### v571 — 2026-03-05
**Commit:** `4f5503d`
**Changes:** Search page fixes:
- Blank query early return (prevents 3 wasted DB queries)
- `.limit(50)` on all 3 search queries (was unbounded)
- N+1 fix: removed `word.crosswords.size` from word result cards
- Nil-safe `&.any?` guards in view for blank query path
- Controller specs migrated from should→expect()
- 4 new live_search request specs
**Migration:** None
**Rollback:** `git revert 4f5503d`
**Post-deploy:** Clean. Release phase exit 0 (no-op migration). Puma up ~4s. All pages 200. No errors.

### v570 — 2026-03-05
**Commits:** `674e579`, `179edb7`, `39a8da0`, `1c5a234`
**Changes:** 3-feature deploy — word/clue detail pages, notifications polish, new puzzle form:
- Word/clue detail: `.includes(:user)` N+1 fix on crosswords_by_title (Word, Clue, Phrase), page titles, SQL `.order(:difficulty)` replacing Ruby sort, word length subtitle, difficulty dots (●●○○○), empty state guard, spec syntax modernization (should → expect)
- Notifications: click-to-mark-read Stimulus controller, mark-all-read Turbo Stream fix, bell ARIA, deleted actor guard, mobile dropdown unread bg, empty state icon, 8 new specs
- New puzzle form: validation re-render (was redirect), disable_with on submit, void toggle removed from preview, spin.min.js deleted + CSS spinner overlay, error display, aria-hidden on preview, 5 new request specs
**Migration:** None
**Rollback:** `git revert 1c5a234 39a8da0 179edb7 674e579`
**Post-deploy:** Clean. Release phase exit 0. Puma up ~4s. No errors.

### v569 — 2026-03-05
**Commits:** `0a4e44e`, `150b44c`, `e141d1c`, `5abe26c`
**Changes:** 4-feature deploy — solution choice, create dashboard, profile, changelog:
- Solution choice: BEM class rename (.metadata→.xw-solutions-meta, .trash-td→.xw-solutions-table__delete), a11y (caption, sr-only headers, icon titles), thumbnail overflow fix, chevron-right icon, tablet columns
- Create dashboard: `before_action :ensure_logged_in` (was showing "You're not logged in"), `row_top_title`, BEM section headings + count badges, empty state with icon, ordered queries (updated_at desc), updated spec
- Profile: hide "In Progress" stat from other users (was leaking draft count), "Edit Profile" link on own profile, location display, avatar 140→120px (matches upload version), simplified `base_crossword` (loop→one-liner), turbo_stream friend accept/reject, 7 new request specs
- Changelog: new `/changelog` page — `GitHubChangelogService` (HTTParty + 1hr cache), date-grouped timeline with category badges, SHA links, pagination, footer link, 5 request specs
**Migration:** None
**Rollback:** `git revert 5abe26c e141d1c 150b44c 0a4e44e`
**Post-deploy:** Clean. Release phase exit 0. Puma up ~3s. No errors.

### v567 — 2026-03-05
**Commit:** `d846825`
**Changes:** Stats page rebuild — 6-section community dashboard:
- At a Glance: 4 hero cards (puzzles, solves, members, clues)
- Growth: 3 Chart.js line charts (total users, daily signups, puzzles published)
- Puzzle Variety: CSS bar chart of grid size distribution
- Solving: completion rate, avg solvers/puzzle, hint-free rate
- Popular Puzzles: top 5 by solver count (with creator + grid size badges)
- Top Constructors: top 5 by puzzle count
- Progressive disclosure: sections hidden when data < threshold
- All queries: simple COUNT/GROUP BY, `.includes(:user)` on popular puzzles
**Migration:** None
**Rollback:** `git revert d846825` (3 files, pure view/controller/CSS)
**Post-deploy:** Clean. Release phase exit 0. Puma up ~3s. No errors.

### v566 — 2026-03-05
**Commits:** `132be74`, `a2d8ff1`
**Changes:** Edit autosave icon fixes + info pages polish:
- Edit save button: `xw-btn--secondary` → `xw-btn--ghost`, tooltip, "Quicksave" → "Save", trailing space removed, toolbar `width: 100%` for right-align
- Solve save: matching trailing space fix in `update_clock()`
- Stats page: `<hr>` → `.xw-section-divider` (proper spacing token)
- Contact page: restructured from 3 `h2` sections to flowing prose with inline links
- FAQ + Contact: added "Browse Puzzles" CTA button at bottom
- Global: row-topper h1 hardcoded `1.4375rem` → `var(--text-2xl)`
- View spec updated: "Quicksave" → "Save" aria-label
**Migration:** None
**Rollback:** `git revert a2d8ff1 132be74` (pure CSS/JS/HAML, instant)
**Post-deploy:** Clean. Release phase exit 0. Puma up ~3s. R12 on old dyno shutdown (cosmetic — new dyno already serving). No app errors.

### v565 — 2026-03-05
**Commit:** `cb6ae20`
**Changes:** Fix edit page void toggle crash — null guard on `next_cell.highlight()`:
- `cell_to_right()` / `cell_below()` return `false` when no non-void cell remains in direction
- Added `if (next_cell)` guard (1 line, `edit_funcs.js`)
**Migration:** None
**Rollback:** `git revert cb6ae20` (single-line JS fix, instant)
**Post-deploy:** Clean. Release phase exit 0. Puma up ~3s. Pages 200. No errors.

### v564 — 2026-03-05
**Commits:** `8791c6c`, `928b0b1`, `34d49db`, `2a32c0c`
**Changes:** Pixel-perfect polish — home, solve, and edit pages:
- Homepage: per_page 36→30, BEM `.xw-load-more__count` class
- Solve: Courier Prime cells (`--font-mono`), tokenized font-sizes/spacing, mask-image byline truncation (replaces gradient pseudo-element), meta-to-footer gap, z-index renumbered (999/1000/1001/1100 → 0/1/2/3)
- Edit: orphaned `<hr>` removed, toggle checkbox a11y (visually-hidden + `:focus-visible` outline), z-index tokenized (`--z-panel: 600`)
- Save buttons: edit + solve swap icon for `.xw-spinner` during AJAX (replaces previous busy/ghost approach)
- Dropdown font: `--font-ui` + `--text-sm` on notification dropdown items
**Migration:** None
**Rollback:** `git revert 2a32c0c 34d49db 928b0b1 8791c6c` (CSS + JS + trivial per_page)
**Post-deploy:** Clean. Release phase exit 0. Puma up ~4s. First request 200. New CSS fingerprints picked up. No errors.

### v560 — 2026-03-05
**Commit:** `a3bed4d`
**Changes:** Edit page frontend review — JS crash fix, tool panel resize, dead code cleanup:
- corresponding_across/down_clue() short-circuit on cw.editing (fixes TypeError after void toggle)
- scroll_to_selected() guard for empty clue set
- Tool panels: 90% viewport → 45vh (puzzle visible above), phone: 60%
- Dead code removed: spin_title(), settings modal + gear button, jquery-ui-1.10.4.draggable.min.js, #tools CSS, .ui-draggable CSS
- Phone switch labels: tighter gap + smaller font
**Migration:** None
**Rollback:** `git revert a3bed4d` (pure JS/CSS/HAML, instant)
**Post-deploy:** Clean. Release phase exit 0. Puma up ~4s. No errors.

### v557 — 2026-03-05
**Commit:** `908c4f5`
**Changes:** 3-item deploy — edit save bugs (critical), account settings rebuild, home page polish:
- Edit: update_letters void/empty/letter fix, save_puzzle preventDefault, save button alignment
- Account: single-page layout, email/username editing, notification prefs (5 JSONB toggles), account deletion (anonymize!)
- Home: puzzle card flexbox, H1 tokens, HR removed, tab icons, byline italic, card hover lift
- 10 views with deleted? guards, login blocked for deleted accounts
- 34 new specs (948 total), diagnostic void corruption rake task
**Migration:** `20260305013832_add_account_settings_columns_to_users` — `notification_preferences` JSONB + `deleted_at` datetime (0.38s)
**Rollback:** `git revert 908c4f5` (migration columns harmless if code reverted)
**Post-deploy:** Clean. Migration in release phase (0.38s). Puma up ~4s. No errors.
- `repair:diagnose_void_corruption` — 1 flagged (UCW #17 "Untitled tester", 85.9% voids — test puzzle)
- `repair:void_cells` — 0 fixes needed (already clean from prior run)

### v555 — 2026-03-05
**Commit:** `4ac4d7b`
**Changes:** Loading feedback system — 4 layers across 17 app files (JS + CSS + HAML):
- Layer 1: Global Turbo nav dimming (`.xw-loading` on clicked elements, spinner on puzzle cards)
- Layer 2: `disable_with` on 16 form buttons (login, signup, publish, friend actions, admin, etc.)
- Layer 3: Solve toolbar busy state (`.xw-btn--busy` spinner, `.xw-btn--saved` green pulse)
- Layer 4: Edit pattern search wired to `loading_controller.js`
**Migration:** None
**Rollback:** `git revert 4ac4d7b` (pure JS/CSS/HAML, instant)
**Post-deploy:** Clean. Release phase exit 0. Puma up ~4s. No errors.

### v554 — 2026-03-05
**Commit:** `dd1c98d`
**Changes:** Visual design review — 12 items across 17 files (CSS + HAML only):
- Empty states: new `.xw-empty-state` component (home ×3, NYT ×2, user-made)
- Sticky footer: flexbox body + `flex: 1 0 auto` on `#body`
- Nav hamburger labels: `.xw-nav__label` spans (hidden desktop, visible mobile)
- Error/auth pages: centered icon + layout (unauthorized, account_required)
- Contact page: editorial section headers
- CTA button fix: `.xw-prose a:not(.xw-btn)` prevents green-on-green
- Forgot Password: red button → accent green, copy fix
- Account settings: vertical tabs → horizontal
- New Puzzle preview: centered with flex
- Profile stats: `font-ui` + `color-text`
- Banner padding, search placeholder quote fix
**Migration:** None
**Rollback:** `git revert <commit>` (pure frontend, instant)
**Post-deploy:** Clean. Release v554. Assets recompiled (6 CSS files, new fingerprints). All pages 200. No errors.

### v552 — 2026-03-05
**Commit:** `ee2ce36`
**Changes:** Deployer persona test-run guardrails, memory file updates (docs only, no app code)
**Migration:** None
**Rollback:** `git revert ee2ce36` (trivial, no app impact)
**Post-deploy:** Clean. Release phase exit 0. Puma up ~3s. No errors.

### v550 — 2026-03-04
**Commits:** `c710d75`, `6d2bce7`
**Changes:**
- Solve timer: client-side MM:SS/H:MM:SS count-up from solution.created_at, freezes on win
- Next puzzle link in win modal (new_to_user scope for logged-in, random for anon)
- Profile N+1 fix: 3 precomputed counts in UsersController#show
- FriendshipService extraction from FriendRequestsController (8 specs)
- Error/unauthorized/account_required page modernization (icons, titles, copy)
**Migration:** None
**Rollback:** `git revert 6d2bce7 c710d75`
**Post-deploy:** Clean. Release phase exit 0. Puma up ~3s, state → up. No errors.

### v549 — 2026-03-04
**Commits:** `7f225ce`, `24fd3c9`, `dd9e2ab`, `354eb35`
**Changes:**
- Vendor Chart.js v4 locally (CDN dependency removed)
- CLAUDE.md cleanup: removed stale architecture/risk sections, updated test count
- New request specs: login, logout, redirect security
- Persona memory file updates
**Migration:** None
**Rollback:** `git revert 354eb35 dd9e2ab 24fd3c9 7f225ce`
**Post-deploy:** Clean. Puma up ~3s. No errors.

### v548 — 2026-03-04
**Commits:** `e721c27`, `1c657c6`, `9487159`
**Changes:**
- NYT calendar: smart init, year nav buttons, skip-empty-months, puzzle count in header
- BEM rename: `.result-crossword` → `.xw-puzzle-card`, `.puzzle-tabs` → `.xw-puzzle-grid` (7 view files)
- Stats page: Chart.js v0 → v4 CDN, Stimulus `stats` controller, vendored `chart.min.js` deleted
**Migration:** None
**Rollback:** `git revert 9487159 1c657c6 e721c27`
**Post-deploy:** Clean. Release phase exit 0 (no-op migration). Puma restarted ~3s, state → up. Pages returning 200. WebSocket connected. No errors.

### v546 — 2026-03-04
**Commit:** `ea7a63c`
**Changes:** NYT page day-of-week tabs + calendar view. Stimulus `nyt-view` controller toggles between tabs/calendar. `nyt-calendar` controller renders monthly grid from JSON data attribute. 7 day-of-week tabs with puzzle counts. New CSS in `_nyt.scss`. 6 new request specs.
**Migration:** None
**Rollback:** `git revert ea7a63c`
**Post-deploy:** Deployed externally. Verified origin + heroku at same commit. Tests: 891 examples, 0 failures.

### v545 — 2026-03-04
**Commit:** `8bedb41`
**Changes:** Show team solution collaborators on solution choice page. Avatars + usernames displayed for each team solution. Helper method for collaborator display.
**Migration:** None
**Rollback:** `git revert 8bedb41`
**Post-deploy:** Deployed externally.

### v544 — 2026-03-04
**Commit:** `43e1621`
**Changes:** Move Switch Solution button to controls row, reuse existing team solutions query. Cleaner placement, no extra DB queries.
**Migration:** None
**Rollback:** `git revert 43e1621`
**Post-deploy:** Deployed externally.

### v543 — 2026-03-04
**Commit:** `f8194f5`
**Changes:** Fix 500 on solve page caused by missing `repeat.svg` icon. Added icon safety specs to prevent future missing-asset crashes.
**Migration:** None
**Rollback:** `git revert f8194f5`
**Post-deploy:** Deployed externally. Fixes production 500.

### v542 — 2026-03-04
**Commit:** `414f0a9`
**Changes:** Reveal hints v2 — persistent black tabs on revealed cells, "Hint Word" option, `revealed_indices` JSON column on solutions.
**Migration:** `20260304211850_add_revealed_indices_to_solutions` — `add_column :solutions, :revealed_indices, :text, default: '[]', null: false` (0.33s)
**Rollback:** `git revert 414f0a9` (column harmless if code reverted)
**Post-deploy:** Clean. Migration in release phase. No errors.

### v541 — 2026-03-04
**Commit:** `c2ff36e`
**Changes:** Edit page void/empty cell swap fix: integer 0 vs string "0" normalization, JS hardening, regression test, repair rake task.
**Migration:** None
**Rollback:** `git revert c2ff36e`
**Post-deploy:** Clean. ⚠️ Run `heroku run bundle exec rails repair:void_cells` to fix existing corrupted UCWs.

### v540 — 2026-03-04
**Commits:** `5dc0897`, `cc099c6`
**Changes:** Homepage "Load More" pagination — Turbo Stream offset pagination for all 3 tabs (unstarted, in_progress, solved). Dead code deleted: `CrosswordsController#batch`, `batch.turbo_stream.erb`, `_load_next_button.html.haml`. Bug fix: in-progress empty-state link pointed to self instead of New Puzzles tab. 6 new request specs.
**Migration:** None
**Rollback:** `git revert cc099c6 5dc0897`
**Post-deploy:** Clean. Release phase exit 0. Puma restarted ~3s. Homepage 200.

### v539 — 2026-03-04
**Commit:** `0c8a75d`
**Changes:** Footer redesign — dark bar → transparent centered colophon strip. Single row: nav links · social icons · ©. Removed ul/li wrappers and icons from nav links. Mobile stacks vertically.
**Migration:** None
**Rollback:** `git revert 0c8a75d`
**Post-deploy:** Clean. All pages 200. New CSS fingerprint picked up.

### v538 — 2026-03-04
**Commit:** `13da633`
**Changes:** Reveal Cell / Reveal Word hints on solve page. Hints tracked per solution (`hints_used` column), shown in win modal. Team broadcasting, golden flash, auto-save. 10 new specs.
**Migration:** `20260304203758_add_hints_used_to_solutions` — `add_column :solutions, :hints_used, :integer, default: 0, null: false` (0.35s)
**Rollback:** `git revert 13da633` (column harmless if code reverted)
**Post-deploy:** Clean. Migration in release phase. No errors.

### v537 — 2026-03-04
**Commits:** `1c6aff5`, `9ff2f66`
**Changes:**
- UTF-8 double-encoding fix: encoding guard in `Clue#strip_tags`, `ensure_utf8` in `NytPuzzleFetcher`, 4 new specs
- Welcome page rebuild: Stimulus chalkboard controller, BEM, design tokens, accessibility, mobile dark panels, "Just browsing?" bypass. Dead code deleted: `welcome.js.erb`, `_chalkboard.html.haml`, `layouts.scss.erb`, `_dimensions.scss`

**Migration:** `20260304202449_fix_double_encoded_clues` — reverses double-encoded clue text (6.3s on production, batched `find_each` + `update_column`). Irreversible (data corruption fix).
**Rollback:** `git revert 9ff2f66 1c6aff5` (migration already ran — clues stay fixed, code revert is safe)
**Post-deploy:** Clean. Migration completed in release phase. Puma restarted, state → up. No errors.

### v536 — 2026-03-04
**Commits:** `c0bcbf2` through `3091b3a` (8 commits)
**Changes:**
- Design polish: editorial `.xw-prose` styles (accent bars, ✦ dinkus), `--font-heading` → `--font-display` fix, switch color tokenization, thumbnail shadow tokenization
- Notification dropdown: bell icon opens in-nav dropdown panel (Stimulus controller, lazy-fetch, mark-all-read, ActionCable refresh)
- Admin solve tools: Fake Win, Reveal Puzzle, Clear Puzzle, Flash Cascade (all admin-gated)
- **Default scope removal**: `Crossword` no longer has `default_scope -> { order(created_at: :desc) }`. Explicit `.order(created_at: :desc)` added to 6 controller queries. `.reorder(:title)` → `.order(:title)` in 3 models. Fixes 3 production bugs (random puzzle, search relevance, admin sort).

**Migration:** None
**Rollback:** `git revert 3091b3a..c0bcbf2` (revert all 8). For scope-only rollback: `git revert 3091b3a`.
**Post-deploy:** Clean. Release phase ran (no-op migration, exit 0). Puma restarted in ~3s. First request 200 OK. No errors.

### v534 — 2026-03-04
**Commit:** `f756b03`
**Changes:** Added `release: rake db:migrate` to Procfile (auto-run migrations before dyno restart)
**Migration:** None
**Post-deploy:** Clean

### v533 — 2026-03-04
**Commit:** `8322603`
**Changes:** Full notification system (all 4 phases)
- Notification model + NotificationService + ActionCable channel
- NotificationsController (inbox, mark_read, mark_all_read)
- FriendRequestsController (create/accept/reject)
- PuzzleInvitesController + Stimulus invite_controller
- Nav bell icon with unread badge
- Comment notifications (puzzle + reply)
- Dead code: cable.js, channels/chatrooms.js deleted

**Migration:** `20260304102456_create_notifications` (CREATE TABLE + 4 indexes, 0.8s)
**Rollback:** `git revert 8322603` + `heroku run rake db:migrate:down VERSION=20260304102456`
**Post-deploy:** ⚠️ One 500 during ~15s migration window (see Incidents). Recovered after migration. Login/pages returning 200.

### v532 — 2026-03-04
**Commit:** `95be4ba`
**Changes:** Puzzle preview thumbnails (75px fixed, pixelated, denser grid)
**Migration:** None
**Post-deploy:** Clean

### v531 — 2026-03-04
**Commit:** `2b5612c`
**Changes:** Golden flash cascade for cell check animations
**Migration:** None
**Post-deploy:** Clean

### v529 — 2026-03-04
**Commits:** `3b7ee04`, `dbbea0b`
**Changes:**
- Bug fix: solve-mode row height jump + focus skip
- CrosswordPublisher refactored, dead code deleted
- Persona consolidation (7 → 3 roles)

**Migration:** None
**Post-deploy:** Clean. CSS `.letter` positioning confirmed good on mobile/tablet.

## Infrastructure Notes

- Heroku app: `crosswordcafe`
- Current release: v579
- Stack: Heroku-24, Ruby 3.4.8, Puma 7.2.0 (cluster: 2 workers, 3 threads)
- Redis: redis-silhouetted-63589 (5 active connections, 1.0 hit rate)
- Node.js warning on build (default v24.13.0 for ExecJS/Sprockets) — cosmetic
- Deploy flow: `git push origin master && git push heroku master`
- Procfile release phase: `release: rake db:migrate` — runs migrations before dyno restart (added v534, confirmed working v536)

## Incidents & Resolutions

### 2026-03-04: Brief 500 on v533 deploy (notification system)
**Impact:** 1 request returned 500 during ~15s migration window
**Cause:** `ApplicationController#load_unread_notification_count` runs on every request and queries `notifications` table. Code deployed before migration created the table → `PG::UndefinedTable`.
**Resolution:** Migration completed in 0.8s, 500s stopped immediately.
**Prevention:** Procfile release phase added in v534 — prevents the entire class of problems. Confirmed working in v536 deploy.
