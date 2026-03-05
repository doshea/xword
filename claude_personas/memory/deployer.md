# Deployer Memory

## Deploy History

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
- Current release: v557
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
