# Deployer Memory

## Deploy History

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
- Current release: v533
- Stack: Heroku-24, Ruby 3.4.8, Puma 7.2.0 (cluster: 2 workers, 3 threads)
- Redis: redis-silhouetted-63589 (1 active connection, 1.0 hit rate)
- Node.js warning on build (default v24.13.0 for ExecJS/Sprockets) — cosmetic
- Deploy flow: `git push origin master && git push heroku master`
- **ACTION NEEDED:** Add `release: rake db:migrate` to Procfile to auto-run migrations before web process restarts. This eliminates the 500 window between code deploy and manual migration.

## Incidents & Resolutions

### 2026-03-04: Brief 500 on v533 deploy (notification system)
**Impact:** 1 request returned 500 during ~15s migration window
**Cause:** `ApplicationController#load_unread_notification_count` runs on every request and queries `notifications` table. Code deployed before migration created the table → `PG::UndefinedTable`.
**Resolution:** Migration completed in 0.8s, 500s stopped immediately.
**Prevention:** Two options:
1. Add `release: rake db:migrate` to Procfile (Heroku runs release phase before restarting dynos)
2. For global before_actions referencing new tables, add `rescue ActiveRecord::StatementInvalid` guard during migration window
**Recommendation:** Option 1 (Procfile release phase) is the correct fix — prevents the entire class of problems.
