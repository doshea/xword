# Notifications Full Page Review

**Meta-plan item:** #5 — Notifications Full Page (`/notifications`)
**Date:** 2026-03-04
**Scope:** Style, UX, responsiveness, a11y, logic edge cases

---

## Overall Assessment

The notifications system is **well-architected** — clean model, service object pattern,
ActionCable real-time updates, shared partial between dropdown and full page, proper dedup
indexes, lazy-loading dropdown. CSS is fully tokenized. The code quality is high.

The issues below are mostly **UX gaps** (no way to mark individual notifications as read,
stale "mark all read" button after Turbo Stream) and **a11y omissions** (no ARIA on the
dropdown toggle). No visual design issues — the page matches the rest of the site.

---

## Findings

### 1. No way to mark individual notifications as read — **should-fix**

The `mark_read` controller action exists and works, with a Turbo Stream response that replaces
the notification row and updates the badge. But **nothing in the UI calls it**. There's no
click handler on notification rows and no "mark read" button.

This means `friend_accepted`, `comment_on_puzzle`, and `comment_reply` notifications stay
unread forever unless the user clicks "Mark all read." The `friend_request` and `puzzle_invite`
types have action buttons (Accept/Decline, Join) but don't mark the notification as read when
clicked either.

**Fix:** Make the entire notification row a clickable link that navigates to the relevant page
AND marks the notification as read. For types with a clear destination:
- `friend_request` → actor's profile
- `friend_accepted` → actor's profile
- `comment_on_puzzle` → crossword page
- `comment_reply` → crossword page
- `puzzle_invite` → team path

Wrap `.xw-notification` in a `link_to` the destination, and add a `mark_read` call (either
inline via Turbo or via a before-navigation fetch). Alternatively, add a subtle "mark read"
icon button per row.

**Simplest approach:** Add a Stimulus action on click that fires a background PATCH to
`mark_read` and simultaneously navigates to the destination URL. The navigation can be a
regular link; the mark-read is fire-and-forget.

---

### 2. "Mark all read" button persists after Turbo Stream update — **should-fix**

On the full page, `button_to mark_all_read_notifications_path` is in `.xw-notifications__header`,
which is **outside** the `#notifications-list` Turbo Stream target. After marking all read:
- The Turbo Stream replaces `#notifications-list` with all-read notifications ✓
- The Turbo Stream clears the nav badge ✓
- The "Mark all read" button **remains visible** in the header ✗

Clicking it again is harmless (idempotent) but it's a UX inconsistency. The dropdown handles
this correctly by hiding the button via JS (`btn.style.display = 'none'`).

**Fix options (pick one):**
1. **Wrap the header in a Turbo Frame** — add `id="notifications-header"` and include a
   `turbo_stream.replace "notifications-header"` in `mark_all_read.turbo_stream.erb` that
   re-renders the header without the button.
2. **Use Stimulus** — add a `data-action` on the form that hides the button on submit
   (matches the dropdown's approach).
3. **Move the button inside `#notifications-list`** — then the Turbo Stream replacement
   naturally removes it. (Least clean visually.)

**Recommendation:** Option 1 (Turbo Frame wrap). Most declarative, no JS needed.

---

### 3. Dropdown bell button missing ARIA attributes — **should-fix**

The notification bell `%button` has no `aria-expanded`, `aria-haspopup`, or `aria-controls`.
Screen readers can't convey dropdown state. The hamburger button correctly sets `aria-expanded`
via `nav_controller.js`, so the pattern exists — it just wasn't applied to the notification
dropdown.

**Fix:** In `_nav.html.haml`, add to the bell button:
```haml
aria: { expanded: 'false', haspopup: 'true', controls: 'notification-dropdown-panel' }
```
Add `id="notification-dropdown-panel"` to `.xw-notification-dropdown`.

In `notification_dropdown_controller.js`, update `toggle()`:
```js
var btn = this.element.querySelector('[aria-expanded]');
if (btn) btn.setAttribute('aria-expanded', String(isOpen));
```

---

### 4. No pagination — hard cap at 50 notifications — **suggestion**

The `.recent` scope does `order(created_at: :desc).limit(50)`. Both the full page and
dropdown use this same scope. Notifications older than the 50th are unreachable.

For a social/puzzle app this is probably fine — notifications are ephemeral. But if a power
user accumulates many, they silently lose access to older ones.

**Fix (if desired):** Add `will_paginate` or a "Load more" button to the full page. The
dropdown should stay at 50 (it's a preview panel). Low priority — only matters if users
complain.

---

### 5. Deleted actor causes crash — **should-fix**

`User` has `has_many :notifications, dependent: :destroy` for the **recipient** side only.
There's no `has_many :notifications_as_actor` with `dependent:` on User, and no DB foreign
key constraint on `actor_id`.

If a user who triggered notifications gets deleted:
1. Their notifications-as-recipient are destroyed (correct)
2. Their notifications-as-actor remain with dangling `actor_id`
3. The partial calls `notification.actor` → `nil`
4. Then `actor.display_name` → `NoMethodError: undefined method 'display_name' for nil`

**Current risk:** Low — user deletion is admin-only and rare. But it's a latent crash.

**Fix:** Add to `User` model:
```ruby
has_many :triggered_notifications, class_name: 'Notification',
         foreign_key: :actor_id, dependent: :destroy
```
Or if you want to preserve notification history when actors are deleted, add a nil guard in
the partial:
```haml
- actor = notification.actor
- return unless actor  # or render a "deleted user" fallback
```
**Recommendation:** `dependent: :destroy` is cleanest — if the actor is gone, the notification
is meaningless.

---

### 6. `puzzle_invite` with missing `team_path` generates broken link — **nitpick**

The partial checks `notification.metadata['crossword_title']` but not `team_path` independently:
```haml
- if notification.metadata['crossword_title']
  = link_to notification.metadata['crossword_title'],
            notification.metadata['team_path']
```
If `crossword_title` is set but `team_path` is nil, `link_to` renders a link to the current
page. In practice both are always set together, so this is theoretical.

**Fix (if desired):** Guard on `team_path` presence:
```haml
- if notification.metadata['crossword_title'] && notification.metadata['team_path']
```

---

### 7. `comment_on_puzzle` / `comment_reply` missing terminal punctuation — **nitpick**

For `comment_on_puzzle` with metadata:
```
"John commented on My Puzzle"
```
No period at the end. The `friend_request` type has a period ("sent you a friend request.")
but the comment types don't when the crossword link is present.

Similarly for `comment_reply`:
```
"John replied to your comment on My Puzzle"
```

And `puzzle_invite`:
```
"John invited you to team-solve My Puzzle"
```

**Fix:** Add trailing periods after the crossword link in all cases. Consistent punctuation.

---

### 8. Dropdown text colors on mobile don't override unread accent border — **nitpick**

Mobile dropdown CSS (lines 579-587 of `_nav.scss`) sets notification text to `--color-nav-text`
but doesn't override `.xw-notification--unread`'s `background-color: var(--color-surface-alt)`.
On the dark mobile nav background, an unread notification would show a cream/tan background
block, which could look jarring.

**Fix:** Add to the mobile dropdown overrides:
```scss
.xw-notification-dropdown__list .xw-notification--unread {
  background-color: rgba(255, 255, 255, 0.10);
}
```

---

### 9. Full page empty state could use an icon — **suggestion**

The full page empty state is:
```haml
#notifications-empty.xw-notifications__empty
  %p No notifications yet.
```

Just plain text, centered. Other pages (user-made, search) have icons with their empty states.
Adding a bell icon and a brief explanation would match the rest of the site.

**Suggestion:**
```haml
#notifications-empty.xw-notifications__empty
  = icon('bell', size: 32)
  %p No notifications yet.
  %p.xw-notifications__empty-hint
    You'll see activity here when friends interact with you.
```

---

## Summary Table

| # | Issue | Severity | Effort |
|---|-------|----------|--------|
| 1 | No individual mark-as-read UI | should-fix | Medium |
| 2 | "Mark all read" button persists after Turbo Stream | should-fix | Small |
| 3 | Missing ARIA on dropdown toggle | should-fix | Small |
| 4 | No pagination (50 cap) | suggestion | Medium |
| 5 | Deleted actor causes crash | should-fix | Small |
| 6 | `puzzle_invite` missing `team_path` guard | nitpick | Tiny |
| 7 | Inconsistent terminal punctuation | nitpick | Tiny |
| 8 | Mobile unread bg color in dropdown | nitpick | Tiny |
| 9 | Empty state could use icon + hint | suggestion | Small |

**Recommended Builder scope:** Items 1–3, 5 (the should-fixes). Items 6–8 can be bundled
as quick polish. Items 4 and 9 are optional enhancements.

---

## Implementation Order (for Builder)

1. **Item 5** — Actor nil guard / dependent destroy (prevents crash, smallest change)
2. **Item 3** — ARIA attributes on dropdown toggle (small, isolated)
3. **Item 2** — Turbo Stream header replacement for mark-all-read
4. **Item 1** — Click-to-mark-read + navigate (largest change, depends on understanding
   the notification row as a clickable unit)
5. **Items 6–8** — Bundled nitpick polish pass
