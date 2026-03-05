# Profile Page Review (`/users/:id`)

**Reviewer:** Planner · 2026-03-04
**Scope:** Logic, UX, edge cases
**Files reviewed:** `UsersController#show`, `users/show.html.haml`,
`users/partials/_user.html.haml`, `users/partials/_friend_status.html.haml`,
`profile.scss.erb`, `Comment#base_crossword`, `FriendRequestsController`,
`FriendshipService`, `AccountPicUploader`, `spec/requests/users_spec.rb`

---

## Summary

The profile page is in **good shape** — polished visually, well-tested (12 request specs
covering show, deleted user, friendship status, CRUD, password, delete), with proper
N+1 mitigation already in place. No must-fix issues. The findings below are a mix of
logic/UX improvements and minor code cleanup.

---

## Findings

### 1. "In Progress" stat leaks draft count to all visitors — **should-fix**

```ruby
# UsersController#show
@in_progress_count = @user.unpublished_crosswords.count
```

The hero card shows how many unpublished crosswords (drafts) a user has — visible to
**everyone**, not just the profile owner. This is private creative work that shouldn't
be exposed to other users.

**Fix:** Only show the "In Progress" stat when `@current_user == @user`. On other
people's profiles, either hide it entirely or replace it with a different public stat
(e.g., total friends count, or remove the 4th column).

---

### 2. No "Edit Profile" link on own profile — **suggestion**

When viewing your own profile, there's no way to get to account settings. The only
path is through the nav dropdown. A small "Edit Profile" link or pencil icon in the
hero card (visible only to the profile owner) would improve discoverability.

**Fix:** Add a conditional link to `account_users_path` when `@current_user == @user`,
styled as a ghost button or icon in the hero info area.

---

### 3. Accept/Decline friend request: full-page redirect instead of in-place update — **suggestion**

The `FriendRequestsController#create` (Add Friend) correctly responds with `turbo_stream`
to replace the `friend-status-#{id}` frame in-place. But `#accept` and `#reject` only
respond with `format.html { redirect_to notifications_path }`.

If someone clicks **Accept** or **Decline** on a profile page, they get yanked away to
the notifications page instead of seeing an in-place status update.

**Fix:** Add `format.turbo_stream` to `accept` and `reject` actions that replace the
`friend-status-#{id}` frame with the updated status (`:friends` for accept, `:none` for
reject). Keep the HTML fallback for non-Turbo requests.

---

### 4. No unfriend mechanism anywhere — **suggestion** (feature gap)

The "Friends!" badge is a static `<span>` with no action. Once a friendship is created,
there is no way to dissolve it from the UI. There's no unfriend route, controller action,
or button anywhere in the app.

**Fix (if desired):** Add a `DELETE /friendships/:id` route or unfriend action. On the
profile page, replace the static "Friends!" badge with a dropdown or hover-reveal that
includes "Unfriend". This is a feature decision, not a bug — flag for product consideration.

---

### 5. Profile avatar upscaled: 120px image rendered at 140px — **nitpick**

`AccountPicUploader` `search` version is 120×120px. The profile hero CSS renders the
avatar at 140×140px on desktop (120×120px on mobile). This causes slight blurriness on
desktop due to upscaling.

**Fix:** Either:
- (a) Add a `profile` version at 140×140px (or 280×280 for retina) to the uploader, or
- (b) Change the CSS to render at 120×120px on desktop too (simpler, no migration needed)

Option (b) is simpler and 120px is still a generous avatar size. Recommend (b).

---

### 6. Over-specified `includes` on comments — **nitpick**

```ruby
.includes(:crossword, base_comment: [:crossword, { base_comment: :crossword }])
```

Comments are max 2 levels deep (enforced by `CommentsController#reply` line 35:
`return head :unprocessable_entity if @base_comment.base_comment_id.present?`).
The third level `{ base_comment: :crossword }` is dead weight.

**Fix:** Simplify to:
```ruby
.includes(:crossword, base_comment: :crossword)
```

Add a comment explaining the 2-level nesting limit for future readers.

---

### 7. Location field exists but is never displayed — **nitpick**

`User` has a `location` column (string, 255 chars). It's writable via `update_user_params`
but never displayed on the profile page. If location is an intended feature, it should
appear in the hero card. If it's vestigial, it should be noted as potential dead schema.

**Recommendation:** Display location in the hero card under the "Member since" line,
only when present. Or add to the tech debt list for future cleanup.

---

### 8. `base_crossword` method is over-engineered — **nitpick**

The `while` loop with `Set`-based cycle detection handles arbitrary depth, but since
nesting is capped at 2 levels, a simple method would suffice:

```ruby
def base_crossword
  crossword || base_comment&.crossword
end
```

This is purely a readability improvement. The current code works correctly. Low priority.

---

## What's Already Good

- **Deleted user handling** — redirect with flash message, tested
- **N+1 queries** — comments preloaded correctly, crosswords via association
- **Pagination** — two independent paginated sections with separate param names
- **Empty states** — both puzzles and comments have italic muted placeholders
- **Friend status** — correctly computed with 4 states, Turbo Frame for create action
- **CSS** — fully tokenized, responsive (phone/desktop breakpoints), BEM naming
- **Test coverage** — 12 request specs covering show, deleted, friendships, CRUD, etc.
- **Security** — `find_by` (not bare `find`), auth bypass test, strong params

---

## Prioritized Builder Punch List

If picking this up, recommended order:

1. **Hide "In Progress" stat from other users** (should-fix, 5 min)
2. **Add turbo_stream to accept/reject** (suggestion, 15 min)
3. **Add "Edit Profile" link on own profile** (suggestion, 5 min)
4. **Simplify includes** (nitpick, 2 min)
5. **Avatar size: CSS → 120px** (nitpick, 2 min)
6. **Display location if present** (nitpick, 5 min)
7. **Simplify `base_crossword`** (nitpick, 5 min)
8. **Unfriend feature** (feature gap, 30+ min — separate ticket)
