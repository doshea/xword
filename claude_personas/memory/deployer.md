# Deployer Memory

## Deploy History

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
- Current release: v540
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
