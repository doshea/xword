# Product Spec: Unfriend Feature

## Problem

Users can send friend requests and accept them, but there's no way to unfriend someone.
The friendship is permanent once accepted. This is a basic social feature gap.

## Solution

Add an "Unfriend" action to user profiles, with confirmation and clean cascade behavior.

---

## User Flow

1. User A visits User B's profile
2. Current state shows "Friends!" badge/button (status `:friends`)
3. User A clicks "Friends!" button → dropdown appears with "Unfriend" option
4. Clicking "Unfriend" shows confirmation: "Remove [name] as a friend?"
5. On confirm → Friendship record deleted, both users' friend lists updated
6. Profile now shows "Add Friend" button (status `:none`)

### Why Dropdown Instead of Direct Button

A prominent "Unfriend" button feels hostile and invites accidental clicks. The "Friends!"
button should feel like a positive status indicator. The unfriend action is intentionally
one click deeper — same pattern as Facebook, Instagram, etc.

---

## Data Changes

### Cascade Behavior

| Related Data | On Unfriend | Rationale |
|-------------|-------------|-----------|
| `Friendship` record | **Delete** | Core action |
| `SolutionPartnering` records | **Keep** | Shared solutions are historical fact. Unfriending shouldn't erase puzzle progress. |
| `FriendRequest` records | **None to delete** | Friend requests are deleted when accepted (via `FriendshipService.accept`) |
| Notifications | **Keep** | Historical. The "X accepted your friend request" notification stays but is inert. |
| Team solutions | **Keep access** | If they're partnered on a solution, they can still access it. `Solution#accessible_by?` checks `solution_partnerings`, not friendships. |

**Key decision:** Unfriending is a social action, not a data purge. It removes the relationship
label but doesn't destroy shared history.

### Can They Re-Friend?

Yes. After unfriending, the profile shows "Add Friend" (status `:none`). Either user can
send a new friend request. No cooldown or block — that's a separate feature if ever needed.

---

## Implementation

### Backend

**New action in `FriendshipService`:**
```ruby
def self.unfriend(user:, friend:)
  Friendship.where(user_id: user.id, friend_id: friend.id)
            .or(Friendship.where(user_id: friend.id, friend_id: user.id))
            .delete_all
end
```

No transaction needed — single delete operation. No notifications to send (unfriending
is a quiet action; the other user simply sees "Add Friend" next time they check).

**New controller action** in `FriendRequestsController` (or new `FriendshipsController`):

Option A: Add `destroy` to `FriendRequestsController`
- Pro: Friendship lifecycle all in one controller
- Con: Controller name implies "requests" not "friendships"

Option B: New `FriendshipsController` with `destroy` only
- Pro: RESTful, clear naming
- Con: Single-action controller feels over-engineered

**Recommendation:** Option A. The controller already handles accept/reject. Add `destroy`
for unfriend. It's the friendship lifecycle controller in practice.

```ruby
# DELETE /friend_requests/unfriend
def unfriend
  friend = User.find_by(id: params[:friend_id])
  return head :not_found unless friend

  FriendshipService.unfriend(user: @current_user, friend: friend)

  respond_to do |format|
    format.turbo_stream do
      render turbo_stream: turbo_stream.replace(
        "friend-status-#{friend.id}",
        partial: 'users/partials/friend_status',
        locals: { user: friend, status: :none }
      )
    end
  end
end
```

### Route

```ruby
delete 'friend_requests/unfriend', to: 'friend_requests#unfriend', as: :unfriend
```

### Frontend

Update `_friend_status.html.haml` for the `:friends` status case:

**Current:**
```haml
- when :friends
  %span.xw-btn.xw-btn--ghost.xw-btn--sm{disabled: true} Friends!
```

**New:**
```haml
- when :friends
  .xw-friend-menu
    %button.xw-btn.xw-btn--ghost.xw-btn--sm.xw-friend-menu__trigger{type: 'button'}
      = icon('check', size: 14)
      Friends
    .xw-friend-menu__dropdown
      = button_to 'Unfriend', unfriend_path(friend_id: user.id),
        method: :delete, class: 'xw-friend-menu__item xw-friend-menu__item--danger',
        data: { turbo_confirm: "Remove #{user.display_name} as a friend?" }
```

### CSS

```scss
.xw-friend-menu {
  position: relative;
  display: inline-block;

  &__dropdown {
    display: none;
    position: absolute;
    top: 100%;
    right: 0;
    background: var(--color-surface);
    border: 1px solid var(--color-border);
    border-radius: var(--radius-md);
    box-shadow: var(--shadow-md);
    z-index: var(--z-dropdown);
    min-width: 120px;
  }

  &__trigger:focus + &__dropdown,
  &__dropdown:hover {
    display: block;
  }

  &__item--danger {
    color: var(--color-danger);
  }
}
```

**Alternative CSS approach:** Use `:focus-within` on `.xw-friend-menu` to show dropdown.
Same pattern as comment action overlays. Builder decides based on existing dropdown patterns.

---

## Files Touched

| File | Change |
|------|--------|
| `app/services/friendship_service.rb` | Add `self.unfriend(user:, friend:)` |
| `app/controllers/friend_requests_controller.rb` | Add `unfriend` action |
| `config/routes.rb` | Add `delete 'friend_requests/unfriend'` |
| `app/views/users/partials/_friend_status.html.haml` | Dropdown with Unfriend option |
| SCSS (components or profile) | `.xw-friend-menu` dropdown styles |

## Acceptance Criteria

1. "Friends" button on profile shows dropdown with "Unfriend" option
2. Clicking "Unfriend" shows browser confirmation dialog
3. Confirming removes the Friendship record (both directions)
4. Profile updates to show "Add Friend" via Turbo Stream (no page reload)
5. Shared solutions remain accessible to both users
6. Either user can re-send a friend request after unfriending
7. No notification sent to the unfriended user
8. `bundle exec rspec` passes
