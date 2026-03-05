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
- **Phase 2:** ✅ Done. 7 reviewed, 6 built, deployed v576–v578. Stats perf = no build needed.
- **Phase 3:** 🔄 Active. 6/8 deployed (D1: 924e958, D2: a1c069e). 2 remaining: P3-E (spinners, reviewed), P3-H (nav, reviewed with corrections). Both queued for Builder.

### P3-E Loading State Spinners review (2026-03-05)
- Upgraded from "Direct" to "Review" — 3 non-obvious findings:
  1. `.xw-loading-placeholder` class has ZERO CSS rules — Builder must add styles
  2. `LoadingController.submit()` uses `.value` which works for `<input type="submit">` but not `<button>` — need tagName-aware logic (also prevents P3-H latent bug)
  3. Home load-more `disable_with` renders HTML via innerHTML — should work, but Builder should verify no escaping
- Plan written: `claude_personas/plans/loading-state-spinners.md`

### P3-H Solve Page Navigation review corrections (2026-03-05)
- **Must-fix**: `send.svg` does NOT exist in icons/ (41 icons available). Plan specifies `icon('send', size: 14)`. Builder must download from Feather icons (https://feathericons.com) or use `arrow-right.svg` (exists).
- **Confirmed**: `arrow-left.svg` exists ✓
- **Note**: If P3-E fixes LoadingController for `<button>`, P3-H Send button gets spinner-on-disable for free

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

### Phase 3 audit findings summary (2026-03-05)
- Codebase is in excellent shape after P1+P2. No structural issues. Remaining work is polish.
- Dead code: `include TimeHelper` (module missing), `letters_to_clue_numbers` (47-line dead method), stale TODO
- Token gaps: 8 instances of hardcoded `#fff` — need `--color-text-on-dark` token
- Admin forms unstyled: 6 edit views use bare Rails helpers, no BEM wrappers
- Solve page: no back/home button, save status too muted, comment needs mobile send button
- Save/autosave: working but invisible — users can't tell when saves happen
- Loading states: 3 places show text-only "Loading..." without spinner (home load-more, NYT tabs, search)
- Form validation: `.xw-input--error` CSS exists but no form uses inline field-level errors
- UX flows generally smooth: anonymous→signup, puzzle creation, account lifecycle all working
- Items deliberately excluded from P3: onboarding (feature not polish), team invitation UI (needs product decision), 500 error page (Rails handles it), RGBA tokenization (overengineering)

### Phase 3 rewrite rationale (2026-03-05)
- Merged old P3-4 (solve UX) + P3-5 (save feedback) into P3-A (solve confidence) — same core problem: "did my work save?"
- Added P3-B (cell composite index) and P3-G (crossword user+date index) — missing from old plan, highest perf ROI
- Added P3-F (random puzzle offset) — `ORDER BY RANDOM()` is a scaling cliff, 5 min fix
- Expanded P3-C (design tokens) from "8 hardcoded #fff" to "12+ hardcoded colors" after full audit
- Deferred P3-3 (admin forms), P3-7 (inline validation), P3-8 (review checklist) to backlog — low ROI
- Key finding: `.xw-btn--saved` CSS animation defined in crossword.scss.erb:1269 but NEVER APPLIED — free win
- Key finding: 6 AJAX error callbacks in solve_funcs.js use `console.warn()` only — users get zero feedback on network failures
- Key finding: `ApplicationController#load_unread_notification_count` uses `.count` on `notifications.unread` — NOT an N+1; `(user_id, read_at, created_at)` index covers it efficiently. Previous audit overblew this.
- Key finding: `ApplicationController#find_object` (line 44) still uses bare `.find()` with rescue — only remaining instance in codebase. Functional but inconsistent. Not worth a separate item; note for Builder if touching that file.

### P3-A Solve Confidence review (2026-03-05)
- 9 AJAX calls in solve_funcs.js: 4 check calls have console-only errors (should-fix), save has status-text-only (suggestion), reveal/hint/admin already use cw.flash (good)
- Edit page does NOT need work — all 3 edit AJAX calls already have user-visible error feedback
- `.xw-btn--saved` CSS (crossword.scss.erb:1269) confirmed pre-built but never wired — free win
- Auto-save retries every 5s via `unsaved_changes` flag — correct behavior, but no escalation after repeated failures
- Chose single error message "Check failed — please try again." for all 4 check calls — users don't distinguish check scope at network layer
- 3-failure threshold for persistent banner balances alarm vs. spam (60s+ of downtime before alarming)
- `animationend` listener chosen over `setTimeout` for save pulse — respects reduced-motion and CSS timing changes
- Optional: edit page `#edit-save` could also get the pulse animation — left as Builder bonus

### P3-C Design token completion review (2026-03-05)
- Full audit found 25 hardcoded colors across 5 SCSS files; 19 get tokenized, 6 intentionally skipped
- `--color-text-inverse` (#f5f0e8) already exists — reuse for all `#fff`/`white` text on colored backgrounds
- 5 new tokens: `--color-overlay-hover` (0.12), `--color-overlay-subtle` (0.06), `--color-overlay-border` (0.20), `--color-overlay-backdrop` (dark 0.6), `--color-tint-hover` (dark 0.06)
- Skipped: mask-image `black` (CSS mask keyword), nav box-shadow (unique shadow), 3 mobile-only notification text opacity values (one-off overrides), footer border (between two overlay tokens)
- **WCAG concern**: `--color-text-inverse` (#f5f0e8) on `--color-danger` (#b84040) = 3.3:1 — passes only for large text. Buttons use `--text-sm` (13px) + `--weight-medium` (500). Builder must verify contrast or use pure `#fff` as `--color-text-on-accent` fallback.
- Opacity normalization: 3 instances of 0.10 → 0.12, 2 instances of 0.02-0.03 → 0.06. All sub-perceptual.

### P3-H Solve Page Navigation review (2026-03-05)
- Home button: `root_url` link, first in `#puzzle-controls`, `.xw-btn--ghost` + arrow-left icon
- Rejected `history.back()` — fails for deep links/bookmarks/new tabs
- Mobile send button: visible on touch (no hover), hidden on hover devices via `@media (hover: hover)`
- Must-fix: jQuery `add_comment_or_reply` only handles Enter keypress. Clicking Send button submits via Turbo but doesn't clear textarea or close reply form. Fix: extract `_submit_comment` shared function, add click handler for `.xw-comment__send`
- Loading controller becomes functional — Send button provides the missing `loading_target: 'button'`
- CSS sibling selector `textarea:focus ~ .xw-comment__hint` preserved — Send button placed after hint
- Reply forms also get Send button for consistency
- 320px viewport risk: 6 toolbar buttons may crowd. Builder should test.

## Open Questions
- No unfriend mechanism exists anywhere in the app — flagged as separate feature ticket
