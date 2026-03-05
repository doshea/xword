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
- **Phase 2:** 2/7 reviewed. DB constraints ✅ (plan ready), service specs ✅ (plan ready). 5 remaining: a11y, API security, NYT pagination, JS cleanup, stats perf.

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

## Open Questions
- No unfriend mechanism exists anywhere in the app — flagged as separate feature ticket
- Should `/api/users` endpoint be auth-gated, scoped to friends-only, or removed entirely? (Decision needed in P2-4 review)
