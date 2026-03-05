# Backend Logic Audit

**Reviewed:** 2026-03-04
**Scope:** All controllers, models, and concerns — auth gaps, mass assignment, N+1, dead code, data integrity

## Summary

The backend is in excellent shape. Strong parameters are used consistently (zero mass assignment risks). N+1 queries are well-guarded with `.includes()` on all major pages. Auth is properly layered with signed cookies, before_actions, and model-level authorization.

The findings below are all incremental improvements — no critical security vulnerabilities.

---

## Should-Fix (4)

### S1. Admin actions use inline guards instead of `before_action`
**Files:** `app/controllers/crosswords_controller.rb:174,196`

`admin_fake_win` and `admin_reveal_puzzle` use `return head :forbidden unless @current_user&.is_admin` inline instead of `before_action :ensure_admin`. Functionally equivalent today, but:
- Inconsistent with every other admin-gated action in the app
- If someone edits the method and moves lines around, the guard could be bypassed

**Fix:** Add to the existing `before_action` block:
```ruby
before_action :ensure_admin, only: [:admin_fake_win, :admin_reveal_puzzle]
```
Then remove the inline `return head :forbidden` lines.

### S2. SolutionPartnering has zero validations
**File:** `app/models/solution_partnering.rb`

No presence, no uniqueness. The DB has individual indexes on `user_id` and `solution_id` but **no compound unique index**. `CrosswordsController#team` calls `find_or_create_by` which works, but nothing prevents duplicates via console, rake, or future code paths.

**Fix:**
```ruby
validates :user_id, uniqueness: { scope: :solution_id }
```
Plus a migration to add the compound unique index:
```ruby
add_index :solution_partnerings, [:solution_id, :user_id], unique: true
```
Note: This was also flagged in the team-solving review (plan #10). Builder can handle both together.

### S3. Missing `dependent:` on Crossword → favorite_puzzles
**File:** `app/models/crossword.rb:44`

```ruby
has_many :favorite_puzzles, inverse_of: :crossword  # missing dependent:
```

User model has `dependent: :destroy` on its side, but if a crossword is destroyed, its favorite_puzzles become orphaned rows. In practice crosswords are rarely deleted, but data integrity should be symmetric.

**Fix:** Add `dependent: :destroy` to the association.

### S4. Missing `dependent:` on User → friendship associations
**File:** `app/models/user.rb:39-42`

```ruby
has_many :friendship_ones, class_name: 'Friendship', foreign_key: :friend_id  # no dependent:
has_many :friendship_twos, class_name: 'Friendship', foreign_key: :user_id    # no dependent:
```

If a user is deleted, their Friendship records are orphaned. The other side's `friends` query would then reference a non-existent user.

**Fix:** Add `dependent: :destroy` to both.

---

## Suggestions (4)

### G1. Delete 8 unused scopes
**Files:** `app/models/concerns/publishable.rb`, `app/models/solution.rb`, `app/models/cell.rb`

Grep confirms zero usage outside their own definitions:

| Scope | Model | Status |
|-------|-------|--------|
| `:standard` | Publishable | Unused |
| `:nonstandard` | Publishable | Unused |
| `:solo` | Publishable | Unused |
| `:teamed` | Publishable | Unused |
| `:abandoned` | Solution | Unused |
| `:desc_indices` | Cell | Unused |
| `:circled` | Cell | Unused (view checks `cell.circled` attribute directly, not the scope) |
| `:uncircled` | Cell | Unused |

Note: `:asc_indices` on Cell IS used (3 places) — keep it.

**Fix:** Delete all 8.

### G2. Friendship missing self-friendship guard
**File:** `app/models/friendship.rb`

`FriendRequest` has `cannot_send_to_self` validation, but `Friendship` lacks an equivalent. If anything bypasses the FriendRequest flow (admin console, data import), a self-friendship could be created.

**Fix:** Add validation:
```ruby
validate :cannot_befriend_self
private
def cannot_befriend_self
  errors.add(:friend_id, "can't be the same as user") if user_id == friend_id
end
```

### G3. Word missing presence validation on `:content`
**File:** `app/models/word.rb:40`

Has `validates_uniqueness_of :content` but no presence validation. An empty-string word could be created (uniqueness would allow one nil/blank).

**Fix:** Add `validates :content, presence: true`.

### G4. Phrase/Word → clues missing `dependent:`
**Files:** `app/models/phrase.rb:12`, `app/models/word.rb:23`

Neither has `dependent:` on their `has_many :clues`. In practice these records are never deleted, so this is theoretical. If they ever are, orphaned clues would have nil `phrase_id`/`word_id`.

**Fix:** Add `dependent: :nullify` to both (safest — clues survive but lose the link).

---

## Nitpicks (2)

### N1. Unnecessary `includes(:clues)` in live_search
**File:** `app/controllers/pages_controller.rb:102`

The live search view (`_live_results.html.haml`) only accesses `word.content`, not clues. The `.includes(:clues)` is wasted work (single extra JOIN/query).

**Fix:** Remove `.includes(:clues)` from the live_search query.

### N2. String exceptions in populate_cells / set_contents
**File:** `app/models/crossword.rb`

`raise 'Save failed!'` and similar raise bare strings instead of proper exception classes. Not a bug (they're caught), but makes rescue clauses fragile.

**Fix:** Low priority — only matters if rescue logic gets more specific.

---

## Not Issues (Verified Clean)

- **Mass assignment:** All controllers use strong parameters consistently. Zero vulnerabilities.
- **N+1 queries:** All major pages (home, nytimes, user_made, show, profile, admin) properly eager-load.
- **SQL injection:** All raw SQL uses hardcoded constants or parameterized queries.
- **Auth coverage:** All destructive/sensitive actions properly gated. Signed cookie auth is solid.
- **Model callbacks:** Well-scoped, no surprising side effects, `skip_callbacks` guard for tests.
- **Division-by-zero:** Already guarded in Solution#percent_complete/percent_correct.
- **Admin impersonation (clone_user):** Intentional debug feature, behind ensure_admin. Acceptable risk for a small app.
