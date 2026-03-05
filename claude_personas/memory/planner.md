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

- **Tier 1:** ✅ Done. All deployed (v570).
- **Tier 2:** ✅ Done. All 5 reviewed, queued for Builder.
- **Tier 3:** ✅ Done. All 5 reviewed (admin, user-made, team solving, test suite, backend audit).

### Turbo Stream `replace` pattern bug (2026-03-04)
- `password_errors.turbo_stream.erb` and `wrong_password.turbo_stream.erb` use `turbo_stream.replace "password-errors"` but the replacement content lacks the `id="password-errors"` wrapper. First submission works; subsequent ones silently fail (no target). Affects both reset_password and account change-password. Both login/signup and forgot/reset reviews flagged this independently.

### Backend audit — data integrity gaps (2026-03-04)
- SolutionPartnering has zero validations and no compound unique DB index — flagged in both team-solving and backend reviews
- Crossword#favorite_puzzles and User#friendship_ones/twos missing `dependent:` — orphan risk on deletion
- 8 unused scopes identified across Publishable, Solution, Cell — safe to delete

## Open Questions
- ~~FriendRequest model spec uses `should` syntax~~ — captured in test-suite-health.md (147 total `should` occurrences across 20 files)
- No unfriend mechanism exists anywhere in the app — flagged as separate feature ticket
