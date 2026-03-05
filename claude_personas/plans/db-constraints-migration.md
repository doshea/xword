# P2-1: Database Constraints Migration

**Status:** Reviewed
**Severity ratings:** must-fix / should-fix / suggestion / nitpick

---

## Summary

App-level validations protect against casual duplicates but not race conditions. Six tables
have uniqueness enforced only in Ruby — two concurrent requests can both pass `validates_uniqueness_of`
and insert. The codebase already has good patterns for handling `RecordNotUnique` (Phrase, team
key, NotificationService) — this review extends that coverage.

---

## Findings

### 1. `users.email` / `users.username` — no DB unique index (**must-fix**)

**Current state:** `validates :email, uniqueness: true` and `validates :username, uniqueness: true`
in User model. Schema has NO unique index on either column — only `auth_token` has one.

**Risk:** Two concurrent signups with the same email/username both pass the Rails uniqueness
check (SELECT → no match → INSERT). Both succeed. Result: duplicate accounts, broken login
(which one gets auth?), broken profile URLs.

**Fix:**
```ruby
add_index :users, :email, unique: true
add_index :users, :username, unique: true
```

**Pre-migration check:** Query for duplicates first. If any exist (unlikely given the app has
been running a while), dedup before adding the constraint.

```ruby
# In migration, before add_index:
dupes = User.group(:email).having('COUNT(*) > 1').pluck(:email)
raise "Duplicate emails found: #{dupes}" if dupes.any?
```

### 2. `friendships(user_id, friend_id)` — no composite unique index (**must-fix**)

**Current state:** `id: false` table. Individual indexes on `user_id` and `friend_id`. Model
validates `uniqueness: { scope: :friend_id }`. No DB constraint.

**Risk:** Concurrent friend-accept requests create duplicate friendship rows. The `friends`
query uses `.where(user_id:)` + `.or(.where(friend_id:))` — duplicates would inflate friend
lists and break `.exists?` assumptions.

**Fix:**
```ruby
add_index :friendships, [:user_id, :friend_id], unique: true, name: 'index_friendships_on_user_and_friend'
```

**Pre-migration check:** Dedup existing data. Since `id: false`, you can't target by PK —
use raw SQL:
```sql
DELETE FROM friendships f1
USING friendships f2
WHERE f1.ctid > f2.ctid
  AND f1.user_id = f2.user_id
  AND f1.friend_id = f2.friend_id;
```

### 3. `friend_requests(sender_id, recipient_id)` — no composite unique index (**must-fix**)

**Current state:** Same as friendships — `id: false`, individual FK indexes, app-only uniqueness.

**Fix:**
```ruby
add_index :friend_requests, [:sender_id, :recipient_id], unique: true, name: 'index_friend_requests_on_sender_and_recipient'
```

**Pre-migration check:** Same ctid dedup pattern as friendships.

### 4. `words.content` — no DB unique index (**must-fix**)

**Current state:** `validates :content, presence: true, uniqueness: true` in Word model.
`Crossword#generate_words_and_link_clues` calls `Word.find_or_create_by(content: word)`
with NO `RecordNotUnique` rescue. The batch pre-load (`existing_words`) narrows the window,
but two puzzles publishing simultaneously with the same new word can race.

**Fix:**
```ruby
add_index :words, :content, unique: true
```

No dedup concern — Word content is already effectively unique (53K+ entries, bulk-loaded).
Verify in migration anyway.

### 5. `notifications.actor_id` — missing standalone index (**should-fix**)

**Current state:** `actor_id` appears in composite dedup indexes but `user_id` is the leading
column. When a user is deleted, `dependent: :destroy` on `triggered_notifications` runs
`DELETE FROM notifications WHERE actor_id = ?` — sequential scan without a standalone index.

**Fix:**
```ruby
add_index :notifications, :actor_id, name: 'index_notifications_on_actor_id'
```

Low urgency (user deletion is rare) but cheap to add.

### 6. Drop `cell_edits` table (**should-fix**)

**Current state:** Table exists in schema. Model was deleted in Phase 1 code cleanup. Table
has `cell_id` column + index — entirely orphaned.

**Fix:**
```ruby
drop_table :cell_edits
```

### 7. Add `RecordNotUnique` rescue to 3 call sites (**should-fix**)

Now that DB unique indexes will exist on these tables, the `find_or_create_by` calls should
rescue gracefully instead of raising 500s on the rare collision.

**a) `Word.find_or_create_by` in `Crossword#generate_words_and_link_clues` (line 358)**

```ruby
# Before:
the_word = existing_words[word] ||= Word.find_or_create_by(content: word)

# After — match the Phrase pattern:
the_word = existing_words[word] ||= begin
  Word.find_or_create_by(content: word)
rescue ActiveRecord::RecordNotUnique
  Word.find_by!(content: word)
end
```

**b) `SolutionPartnering.find_or_create_by` in `CrosswordsController#team` (line 73)**

```ruby
# Before:
SolutionPartnering.find_or_create_by(solution_id: @solution.id, user_id: @current_user.id)

# After:
begin
  SolutionPartnering.find_or_create_by(solution_id: @solution.id, user_id: @current_user.id)
rescue ActiveRecord::RecordNotUnique
  # Unique index caught duplicate — safe to ignore
end
```

**c) `FavoritePuzzle.find_or_create_by` in `CrosswordsController#favorite` (line 84)**

```ruby
# Before:
fav = FavoritePuzzle.find_or_create_by(user_id: @current_user.id, crossword_id: @crossword.id)

# After:
begin
  fav = FavoritePuzzle.find_or_create_by(user_id: @current_user.id, crossword_id: @crossword.id)
rescue ActiveRecord::RecordNotUnique
  fav = FavoritePuzzle.find_by(user_id: @current_user.id, crossword_id: @crossword.id)
end
```

### 8. Personal solution uniqueness — partial unique index (**suggestion**)

**Current state:** `Solution.find_or_create_by(crossword_id:, user_id:, team: false)` has no
uniqueness constraint. The existing `(crossword_id, user_id)` index is non-unique (intentionally,
since a user CAN have both team and personal solutions for the same crossword).

**Fix (optional):**
```ruby
add_index :solutions, [:crossword_id, :user_id],
          unique: true,
          where: "team = false",
          name: 'index_solutions_on_crossword_user_personal_unique'
```

Plus a rescue in `CrosswordsController#show`:
```ruby
@solution = begin
  Solution.find_or_create_by(crossword_id: @crossword.id, user_id: @current_user.id, team: false)
rescue ActiveRecord::RecordNotUnique
  Solution.find_by(crossword_id: @crossword.id, user_id: @current_user.id, team: false)
end
```

**Risk assessment:** Low-probability race (same user loading same puzzle in two tabs simultaneously).
Not blocking, but defensive. Builder can include or defer — planner recommends including.

---

## Migration Order

Single migration file. Order matters for safety:

1. **Check for duplicates** — raise if any found (users, friendships, friend_requests, words)
2. **Dedup if needed** — only for `id: false` tables (friendships, friend_requests)
3. **Drop `cell_edits`** — independent, do first to simplify
4. **Add unique indexes** — users (email, username), friendships, friend_requests, words
5. **Add `notifications.actor_id` index**
6. **Optional: solutions partial unique index**

```ruby
class AddDatabaseConstraints < ActiveRecord::Migration[8.1]
  def up
    # 1. Pre-flight: verify no duplicates exist
    # (raises if data is dirty — fix manually before re-running)

    # 2. Drop dead table
    drop_table :cell_edits

    # 3. Dedup id:false tables (safe — ctid approach)
    execute <<~SQL
      DELETE FROM friendships f1
      USING friendships f2
      WHERE f1.ctid > f2.ctid
        AND f1.user_id = f2.user_id AND f1.friend_id = f2.friend_id;
    SQL

    execute <<~SQL
      DELETE FROM friend_requests f1
      USING friend_requests f2
      WHERE f1.ctid > f2.ctid
        AND f1.sender_id = f2.sender_id AND f1.recipient_id = f2.recipient_id;
    SQL

    # 4. Add unique indexes
    add_index :users, :email, unique: true
    add_index :users, :username, unique: true
    add_index :friendships, [:user_id, :friend_id], unique: true, name: 'index_friendships_on_user_and_friend'
    add_index :friend_requests, [:sender_id, :recipient_id], unique: true, name: 'index_friend_requests_on_sender_and_recipient'
    add_index :words, :content, unique: true

    # 5. FK index
    add_index :notifications, :actor_id, name: 'index_notifications_on_actor_id'

    # 6. Optional: personal solution uniqueness
    add_index :solutions, [:crossword_id, :user_id],
              unique: true, where: "team = false",
              name: 'index_solutions_on_crossword_user_personal_unique'
  end

  def down
    remove_index :solutions, name: 'index_solutions_on_crossword_user_personal_unique', if_exists: true
    remove_index :notifications, name: 'index_notifications_on_actor_id'
    remove_index :words, :content
    remove_index :friend_requests, name: 'index_friend_requests_on_sender_and_recipient'
    remove_index :friendships, name: 'index_friendships_on_user_and_friend'
    remove_index :users, :username
    remove_index :users, :email

    # Recreate cell_edits for rollback
    create_table :cell_edits do |t|
      t.text :across_clue_content
      t.integer :cell_id
      t.text :down_clue_content
      t.timestamps null: true
      t.index :cell_id
    end
  end
end
```

---

## Files to Touch

| File | Change |
|------|--------|
| `db/migrate/TIMESTAMP_add_database_constraints.rb` | New migration |
| `app/models/crossword.rb` (line ~358) | Add `RecordNotUnique` rescue to Word lookup |
| `app/controllers/crosswords_controller.rb` (line 73) | Rescue on SolutionPartnering |
| `app/controllers/crosswords_controller.rb` (line 84) | Rescue on FavoritePuzzle |
| `app/controllers/crosswords_controller.rb` (line 9) | Rescue on personal Solution (if including #8) |

---

## Acceptance Criteria

- [ ] Migration runs clean on development and Heroku
- [ ] `schema.rb` shows unique indexes on: users.email, users.username, friendships composite, friend_requests composite, words.content
- [ ] `cell_edits` table absent from schema
- [ ] `notifications.actor_id` has standalone index
- [ ] All `find_or_create_by` calls that have backing unique indexes also rescue `RecordNotUnique`
- [ ] `bundle exec rspec` passes (~761 examples, 0 failures)
- [ ] No N+1 or performance regression (indexes only, no query changes)

---

## Risks

1. **Duplicate data in production** — Migration includes dedup for `id: false` tables. For users,
   duplicates are extremely unlikely but the migration should check and abort rather than silently corrupt.

2. **Heroku migration timeout** — Adding 7 indexes + dropping a table. All tables are small
   (<1000 rows except cells/clues). Should complete well within Heroku's 25-minute limit.
   If concerned, use `algorithm: :concurrently` (requires `disable_ddl_transaction!`).

3. **Rollback safety** — `down` method recreates `cell_edits` table and removes all indexes.
   Data in `cell_edits` is lost permanently (acceptable — table has been dead since Phase 1).
