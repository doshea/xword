# Planner Memory

Keep this file lean. Architecture decisions and open questions only.
Per-review details belong in plan files (`claude_personas/plans/<slug>.md`).
Review status tracking lives in the meta-plan (`claude_personas/plans/planner-meta-plan.md`).

## Architecture Decisions (Reference)

### CrosswordPublisher pattern (2026-03-03)
- Class-method-based service (`CrosswordPublisher.publish(ucw)`) following `NytPuzzleImporter` pattern
- Custom `BlankCellsError` for validation failures — controller maps exceptions to redirects
- Team broadcast extraction skipped — SolutionsController's private method is already clean (6 lines)

### Default scope removal rationale (2026-03-04)
- `default_scope` ordering is prepended; subsequent `.order()` calls APPEND (not replace). Only `.reorder()` replaces.
- 3 production bugs fixed: random puzzle always newest, search relevance suppressed, admin sort ignored.

## Review Queue Status

**Source of truth:** `claude_personas/plans/planner-meta-plan.md`

- **Phase 1:** ✅ Done. 16 reviews + changelog, all deployed (v548–v574).
- **Phase 2:** ✅ All 7 reviewed. DB constraints ✅, service specs ✅, API security ✅, NYT pagination ✅, JS cleanup ✅, a11y ✅ (built), stats perf ✅ (no build needed).

### Turbo Stream `replace` pattern bug (2026-03-04)
- `password_errors.turbo_stream.erb` and `wrong_password.turbo_stream.erb` use `turbo_stream.replace "password-errors"` but the replacement content lacks the `id="password-errors"` wrapper. First submission works; subsequent ones silently fail (no target). Affects both reset_password and account change-password. Both login/signup and forgot/reset reviews flagged this independently.

### Backend audit — data integrity gaps (2026-03-04)
- SolutionPartnering has zero validations and no compound unique DB index — flagged in both team-solving and backend reviews
- Crossword#favorite_puzzles and User#friendship_ones/twos missing `dependent:` — orphan risk on deletion
- 8 unused scopes identified across Publishable, Solution, Cell — safe to delete

### Phase 2 audit findings summary (2026-03-05)
- Zero DB-level FK constraints; `users.email`/`username` uniqueness is app-only (race condition risk)
- `friendships` and `friend_requests` tables have `id: false` and no unique composite indexes
- `cell_edits` table is dead (model deleted Phase 1) — drop in migration
- `notifications.actor_id` is the only FK column missing an index
- 3/7 services have zero specs (GithubChangelogService, NytPuzzleFetcher, NytGithubRecorder)
- 6+ forms missing labels/aria-labels; secondary pages missing `<main>` landmarks
- Stimulus controllers missing `disconnect()` cleanup → event listener leaks on Turbo nav
- `/api/users` endpoint returns all users without auth
- NYT page loads 705+ puzzles unbounded; stats page runs COUNT queries every load

### P2-2 Form accessibility audit (2026-03-05)
- `<main>` landmark concern from meta-plan was false alarm — `application.html.haml:23` wraps all content in `%main#body`, including topper_stopper pages
- Edit title input label association is correct — `text_field_tag 'title'` auto-generates `id="title"`
- Reply edit pencil button (`_reply.html.haml:9`) may be dead/unfinished — Builder should check for JS handlers before deciding fix vs delete
- All `a→button` conversions need CSS selector audit (no `a.class` specificity in stylesheets)

### P2-3 Service test coverage review (2026-03-05)
- GithubChangelogService has partial coverage via request spec (skip_commit? + integration), but categorize/strip_prefix/parse_last_page/auth untested at unit level
- NytPuzzleFetcher and NytGithubRecorder are only ever stubbed in other specs — zero actual method execution
- UnpublishedCrossword#letters_to_clue_numbers has a `#TODO make this work` comment — Builder must verify correctness before writing assertions
- Existing service spec pattern: no `type:` metadata, `let` for data, `instance_double` for HTTParty responses
- ENV stubbing pattern needs to be established — no existing precedent in codebase

### P2-1 DB constraints review (2026-03-05)
- Confirmed from schema.rb: users.email and users.username have NO DB unique index (only auth_token does)
- words.content also lacks DB unique index despite model validation — missed in earlier audit
- FavoritePuzzle and SolutionPartnering already have DB unique indexes (added Mar 4-5) but their find_or_create_by calls lack RecordNotUnique rescue
- cell_edits table confirmed dead — safe to drop
- notifications.actor_id needs standalone index for User#triggered_notifications dependent: :destroy
- Recommended including partial unique index on solutions(crossword_id, user_id) WHERE team=false
- Migration includes ctid-based dedup for id:false tables (friendships, friend_requests)
- Existing rescue patterns to follow: Phrase (retry-then-find), team key (retry), NotificationService (silent nil)

### P2-4 API cleanup (2026-03-05, updated)
- User decision: keep ONLY `GET /api/nyt/:year/:month/:day` (GitHub proxy) + relocate `friends`
- Delete: `/api/users/*`, `/api/crosswords/*`, `/api/nyt_source/*`, both API sub-controllers
- Delete: `Crossword#format_for_api`, `Comment#format_for_api` (orphaned by controller deletion)
- Move: `Api::UsersController#friends` → `ApiController#friends` at `/api/friends`
- Update: `_team.html.haml` route helper (`api_users_friends_path` → `api_friends_path`)
- `NytPuzzleFetcher.from_xwordinfo` method stays (used by NytGithubRecorder internally) — only API route removed
- CSP + rate limiting deferred (complex, separate tickets)

### P2-5 NYT pagination review (2026-03-05)
- Chose lazy tab loading over will_paginate or Turbo Frames
- Calendar pluck is already lightweight — no change needed
- Main cost is partial rendering (~705 `_crossword_tab` renders), not DB or memory
- `EXTRACT(DOW FROM created_at)` is fine — only ~705 rows after user_id filter
- TabsController gets generic `data-lazy-src` attr (opt-in, doesn't affect other tab instances)
- Intra-tab pagination deferred — no single day exceeds ~100 puzzles until ~2030

### P2-6 JS event listener cleanup (2026-03-05)
- Full audit of all 15 Stimulus controllers + 13 non-Stimulus JS files + 5 HAML inline scripts
- **3 of 4 meta-plan concerns were false alarms**: Stimulus controllers all have proper disconnect(), jQuery `.on()` doesn't stack (Turbo replaces body), bottom-button handlers same reasoning
- **1 real bug**: `document.onkeydown`/`onkeypress` in crossword_funcs.js:265-266 — property assignment at parse time persists globally after first crossword visit, suppressing arrow/space scrolling on all pages
- Fix: move into existing `_cwTurboLoadHandler` (which already has the `!$('.cell').length` guard), add cleanup when navigating away from crossword pages
- Win modal inline JS (~100 lines) is architecturally impure but not a leak — defer extraction to Stimulus until modal gets a visual redesign
- Corrected Phase 2 audit finding about "Stimulus controllers missing disconnect() cleanup" — this was wrong

### P2-7 Stats page performance (2026-03-05)
- 11 queries, zero caching, total exec <1ms at current scale (5 users, 15 crosswords, 14 solutions)
- Missing indexes on `users.deleted_at`, `users.created_at`, `solutions(is_complete, hints_used)` — all seq scans, all trivial at current row counts
- Redis cache configured in production but unused — highest ROI future change is `Rails.cache.fetch` with 30-min TTL when scale warrants it (~500+ solutions)
- **Decision: no build task.** Monitor and act when scale warrants it. Review filed in `stats-page-performance.md`

### Pre-commit review of P2-1, P2-4, P2-6 (2026-03-05)
- Reviewed all 13 uncommitted files (128 ins, 243 del) across DB constraints, API cleanup, JS fix
- **1 should-fix**: `ApiController#friends` `.select` omits `:deleted_at` but `display_name` calls `deleted?` → `deleted_at.present?` — raises `MissingAttributeError` for deleted users with friendships. Pre-existing bug from old `Api::UsersController`, easy to fix now.
- **1 nitpick**: migration dedup comment says "most recently updated" but uses `id < id` (keeps highest id). Functionally fine.
- Everything else clean: no stale route references, proper addEventListener/removeEventListener pattern, correct pre-flight checks in migration, all specs updated.
- P2-2, P2-3, P2-5 already committed — not reviewed this pass.

## Open Questions
- No unfriend mechanism exists anywhere in the app — flagged as separate feature ticket
