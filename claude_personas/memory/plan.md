# Notification System — Implementation Plan (Builder-Ready)

## Overview

4-phase plan for notifications, friend requests, comment notifications, and puzzle invites. Each phase is independently deployable.

**Predecessor:** This replaces the previous plan review. All must-fix issues have been incorporated into the task descriptions below. The Builder should follow this file as the single source of truth.

---

## Prerequisites (Do Before Phase 1)

### P.0 Download 4 Lucide SVG Icons

Download to `app/assets/images/icons/` from [lucide.dev](https://lucide.dev/icons/). Format: 24×24 viewBox, stroke-based, matching existing icons (see `check.svg`, `user.svg` for style reference).

1. **`bell.svg`** — [lucide.dev/icons/bell](https://lucide.dev/icons/bell) — nav icon + inbox header
2. **`clock.svg`** — [lucide.dev/icons/clock](https://lucide.dev/icons/clock) — "Request Sent" state (Phase 2)
3. **`user-plus.svg`** — [lucide.dev/icons/user-plus](https://lucide.dev/icons/user-plus) — invite heading (Phase 4)
4. **`check-check.svg`** — [lucide.dev/icons/check-check](https://lucide.dev/icons/check-check) — "Mark all read" button

The `icon()` helper (`IconHelper`, `app/helpers/icon_helper.rb`) reads SVGs from `ICON_DIR = Rails.root.join('app', 'assets', 'images', 'icons')`. Missing files will crash at runtime.

---

## Phase 1: Notification Backbone (14 tasks)

### Task 1.1 — Migration: `create_notifications`

**File:** `db/migrate/YYYYMMDDHHMMSS_create_notifications.rb`

```ruby
class CreateNotifications < ActiveRecord::Migration[8.1]
  def change
    create_table :notifications do |t|
      t.integer  :user_id,           null: false  # recipient
      t.integer  :actor_id,          null: false  # who triggered it
      t.string   :notification_type, null: false
      t.string   :notifiable_type                 # polymorphic, nullable
      t.integer  :notifiable_id                   # polymorphic, nullable
      t.jsonb    :metadata,          null: false, default: {}
      t.datetime :read_at                         # null = unread

      t.timestamps
    end

    # Inbox: unread count + listing (user_id, read_at IS NULL, ordered by created_at)
    add_index :notifications, [:user_id, :read_at, :created_at],
              name: 'index_notifications_on_inbox'

    # Cleanup when notifiable is deleted
    add_index :notifications, [:notifiable_type, :notifiable_id],
              name: 'index_notifications_on_notifiable'

    # Dedup: one notification per (user, actor, type, notifiable)
    add_index :notifications,
              [:user_id, :actor_id, :notification_type, :notifiable_type, :notifiable_id],
              unique: true,
              name: 'index_notifications_on_dedup'

    # ⚠️ MUST-FIX: PostgreSQL treats NULLs as distinct in unique indexes.
    # friend_request / friend_accepted have nil notifiable — the above index
    # won't prevent duplicates. This partial index covers the NULL case.
    add_index :notifications,
              [:user_id, :actor_id, :notification_type],
              unique: true,
              where: 'notifiable_type IS NULL',
              name: 'index_notifications_on_dedup_no_notifiable'
  end
end
```

**Column types:** `t.integer` for user_id/actor_id — `users.id` is `integer` (confirmed in schema.rb line 5 of user annotation).

### Task 1.2 — Notification Model

**File:** `app/models/notification.rb`

```ruby
class Notification < ApplicationRecord
  belongs_to :user, inverse_of: :notifications    # recipient
  belongs_to :actor, class_name: 'User'           # who triggered it
  belongs_to :notifiable, polymorphic: true, optional: true

  validates :notification_type, presence: true
  validates :notification_type, inclusion: {
    in: %w[friend_request friend_accepted puzzle_invite comment_on_puzzle comment_reply]
  }
  validate :cannot_notify_self

  scope :unread, -> { where(read_at: nil) }
  scope :recent, -> { order(created_at: :desc).limit(50) }

  private

  def cannot_notify_self
    errors.add(:user_id, "can't notify yourself") if user_id == actor_id
  end
end
```

### Task 1.3 — User Model Associations

**File:** `app/models/user.rb` — add after existing `has_many` block (after line 42):

```ruby
has_many :notifications, inverse_of: :user, dependent: :destroy

has_many :sent_friend_requests, class_name: 'FriendRequest', foreign_key: :sender_id
has_many :received_friend_requests, class_name: 'FriendRequest', foreign_key: :recipient_id
```

### Task 1.4 — Notification Factory

**File:** `spec/factories/notification_factory.rb`

```ruby
FactoryBot.define do
  factory :notification do
    association :user
    association :actor, factory: :user
    notification_type { 'comment_on_puzzle' }
    metadata { {} }

    trait :friend_request do
      notification_type { 'friend_request' }
    end

    trait :friend_accepted do
      notification_type { 'friend_accepted' }
    end

    trait :puzzle_invite do
      notification_type { 'puzzle_invite' }
      association :notifiable, factory: :solution
    end

    trait :comment_on_puzzle do
      notification_type { 'comment_on_puzzle' }
      association :notifiable, factory: :comment
    end

    trait :comment_reply do
      notification_type { 'comment_reply' }
      association :notifiable, factory: :comment
    end

    trait :read do
      read_at { Time.current }
    end
  end
end
```

### Task 1.5 — NotificationService

**File:** `app/services/notification_service.rb`

Follows `CrosswordPublisher` pattern (class methods, no instance state).

```ruby
class NotificationService
  # Single entry point for creating notifications.
  # Returns nil if self-notification (user == actor).
  # Rescues RecordNotUnique silently (dedup index prevents duplicates).
  # Broadcasts to ActionCable after creation.
  def self.notify(user:, actor:, type:, notifiable: nil, metadata: {})
    return nil if user == actor

    notification = Notification.create!(
      user: user,
      actor: actor,
      notification_type: type,
      notifiable: notifiable,
      metadata: metadata
    )

    broadcast(notification)
    notification
  rescue ActiveRecord::RecordNotUnique
    nil  # Dedup index caught a duplicate — silently ignore
  end

  def self.broadcast(notification)
    html = ApplicationController.render(
      partial: 'notifications/partials/notification',
      locals: { notification: notification }
    )

    ActionCable.server.broadcast(
      "notifications_#{notification.user_id}",
      {
        event: 'new_notification',
        html: html,
        unread_count: notification.user.notifications.unread.count
      }
    )
  rescue StandardError => e
    # Don't let broadcast failures prevent notification creation.
    Rails.logger.error("[NotificationService] Broadcast failed: #{e.class} — #{e.message}")
  end
  private_class_method :broadcast
end
```

### Task 1.6 — NotificationsChannel

**File:** `app/channels/notifications_channel.rb`

Follows `TeamsChannel` pattern. Rejects anonymous users (current_user is nil for unauthenticated connections — see `ApplicationCable::Connection#find_verified_user`).

```ruby
class NotificationsChannel < ApplicationCable::Channel
  def subscribed
    if current_user
      stream_from "notifications_#{current_user.id}"
    else
      reject
    end
  end
end
```

### Task 1.7 — ActionCable JS + Notifications Channel JS

**Approach:** ActionCable JS (`actioncable` gem asset) is currently only loaded on team pages via `_team.html.haml` line 1. For notifications, it needs to load on every page for logged-in users.

**File:** `app/views/layouts/application.html.haml` — add conditional JS includes after `= javascript_include_tag "application"` (line 11):

```haml
- if is_logged_in?
  = javascript_include_tag 'actioncable'
  = javascript_include_tag 'notifications_channel'
```

Note: `_team.html.haml` still loads `actioncable` — this is harmless (browser caches the file; Sprockets serves the same asset). Don't remove it from _team since team pages load independently.

**File:** `app/assets/javascripts/notifications_channel.js` (NEW)

```javascript
// ActionCable subscription for real-time notifications.
// Loaded on every page for logged-in users (via application.html.haml).
// Depends on: actioncable.js (loaded before this file).

(function() {
  // Guard: only run if the user is logged in (nav-mail badge exists)
  var navMail = document.getElementById('nav-mail');
  if (!navMail) return;

  var consumer = ActionCable.createConsumer();
  consumer.subscriptions.create('NotificationsChannel', {
    received: function(data) {
      if (data.event === 'new_notification') {
        updateBadge(data.unread_count);
        prependToInbox(data.html);
      }
    }
  });

  function updateBadge(count) {
    var badge = navMail.querySelector('.xw-badge');
    if (count > 0) {
      navMail.classList.add('unread');
      if (!badge) {
        badge = document.createElement('span');
        badge.className = 'xw-badge';
        navMail.querySelector('.xw-nav__icon-btn').appendChild(badge);
      }
      badge.textContent = count > 99 ? '99+' : count;
    } else {
      navMail.classList.remove('unread');
      if (badge) badge.remove();
    }
  }

  function prependToInbox(html) {
    var list = document.getElementById('notifications-list');
    if (!list) return;  // not on inbox page
    var empty = document.getElementById('notifications-empty');
    if (empty) empty.remove();
    list.insertAdjacentHTML('afterbegin', html);
  }
})();
```

### Task 1.8 — Nav Badge + Link

**File:** `app/controllers/application_controller.rb` — add before_action and method:

After `before_action :authenticate` (line 6), add:
```ruby
before_action :load_unread_notification_count
```

In private section, add:
```ruby
def load_unread_notification_count
  @unread_notification_count = @current_user&.notifications&.unread&.count || 0
end
```

This runs after `authenticate` (which sets `@current_user`). The nil-safe chain returns 0 for anonymous users. Single `COUNT(*)` query on the indexed `(user_id, read_at, created_at)` column — sub-millisecond.

**File:** `app/views/layouts/partials/_nav.html.haml` — replace lines 64-69 (the #nav-mail section):

```haml
/ Notifications — #nav-mail preserved (CSS unread pulse animation)
- if is_logged_in?
  .xw-nav__item#nav-mail
    = link_to notifications_path, class: 'xw-nav__icon-btn',
              data: { xw_tooltip: 'Notifications' } do
      = icon('bell')
      - if @unread_notification_count > 0
        %span.xw-badge= @unread_notification_count > 99 ? '99+' : @unread_notification_count
```

Changes:
1. Link now goes to `notifications_path` (was `'#'`)
2. Icon changed from `mail` to `bell`
3. Badge count rendered server-side on page load
4. `#nav-mail` ID preserved for existing `.unread` pulse animation CSS

### Task 1.9 — Badge CSS

**File:** `app/assets/stylesheets/_nav.scss` — add after the `#nav-mail.unread` block (after line 175):

```scss
// Notification badge — red circle with count
.xw-badge {
  position: absolute;
  top: 2px;
  right: 2px;
  min-width: 1.1rem;
  height: 1.1rem;
  padding: 0 0.3rem;
  border-radius: var(--radius-full);
  background-color: var(--color-danger);
  color: #fff;
  font-family: var(--font-ui);
  font-size: 0.65rem;
  font-weight: var(--weight-semibold);
  line-height: 1.1rem;
  text-align: center;
  pointer-events: none;
}
```

`.xw-nav__item` already has `position: relative` (line 133), so absolute positioning works.

### Task 1.10 — Routes

**File:** `config/routes.rb` — add notification routes AND Phase 2 friend_request routes (needed by notification partial's accept/reject buttons to avoid `NoMethodError` on `friend_requests_path`):

After the `resources :words` block (line 73), add:

```ruby
resources :notifications, only: [:index] do
  member do
    patch :mark_read
  end
  collection do
    patch :mark_all_read
  end
end

resources :friend_requests, only: [:create] do
  collection do
    post :accept
    delete :reject
  end
end
```

**Why add friend_request routes in Phase 1:** The notification partial renders accept/reject buttons for `friend_request` type. If these routes don't exist, `friend_requests_path` raises `NoMethodError`. The FriendRequestsController itself is built in Phase 2, but the routes must exist now. Without a controller, visiting these routes would return a 500 — acceptable since no UI triggers them until Phase 2.

### Task 1.11 — NotificationsController

**File:** `app/controllers/notifications_controller.rb`

```ruby
class NotificationsController < ApplicationController
  before_action :ensure_logged_in

  # GET /notifications
  def index
    @notifications = @current_user.notifications
                                  .includes(:actor)
                                  .recent
  end

  # PATCH /notifications/:id/mark_read
  def mark_read
    notification = @current_user.notifications.find_by(id: params[:id])
    return head :not_found unless notification

    notification.update!(read_at: Time.current) if notification.read_at.nil?

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to notifications_path }
    end
  end

  # PATCH /notifications/mark_all_read
  def mark_all_read
    @current_user.notifications.unread.update_all(read_at: Time.current)

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to notifications_path }
    end
  end
end
```

### Task 1.12 — Inbox Views

**File:** `app/views/notifications/index.html.haml`

```haml
- content_for(:title) { 'Notifications | ' }
= render layout: 'layouts/partials/topper_stopper', locals: {columns_class: 'xw-md-center-8'} do
  .xw-notifications
    .xw-notifications__header
      %h1.xw-notifications__title
        = icon('bell')
        Notifications
      - if @notifications.any? { |n| n.read_at.nil? }
        = button_to mark_all_read_notifications_path, method: :patch,
                    class: 'xw-btn xw-btn--ghost xw-btn--sm' do
          = icon('check-check', size: 16)
          Mark all read

    #notifications-list.xw-notifications__list
      - if @notifications.any?
        - @notifications.each do |notification|
          = render partial: 'notifications/partials/notification',
                   locals: { notification: notification }
      - else
        #notifications-empty.xw-notifications__empty
          %p No notifications yet.
```

**File:** `app/views/notifications/partials/_notification.html.haml`

```haml
- actor = notification.actor
.xw-notification{ id: "notification-#{notification.id}",
                   class: ('xw-notification--unread' if notification.read_at.nil?) }
  .xw-notification__avatar
    - if actor.image.present?
      = image_tag actor.image.search.url, alt: actor.display_name,
                  class: 'xw-notification__avatar-img'
    - else
      = image_tag 'default_images/user.jpg', alt: actor.display_name,
                  class: 'xw-notification__avatar-img'
  .xw-notification__body
    .xw-notification__message
      - case notification.notification_type
      - when 'friend_request'
        = link_to actor.display_name, user_path(actor)
        sent you a friend request.
      - when 'friend_accepted'
        = link_to actor.display_name, user_path(actor)
        accepted your friend request!
      - when 'comment_on_puzzle'
        = link_to actor.display_name, user_path(actor)
        commented on
        - if notification.metadata['crossword_id']
          = link_to notification.metadata['crossword_title'],
                    crossword_path(notification.metadata['crossword_id'])
        - else
          your puzzle.
      - when 'comment_reply'
        = link_to actor.display_name, user_path(actor)
        replied to your comment
        - if notification.metadata['crossword_id']
          on
          = link_to notification.metadata['crossword_title'],
                    crossword_path(notification.metadata['crossword_id'])
      - when 'puzzle_invite'
        = link_to actor.display_name, user_path(actor)
        invited you to team-solve
        - if notification.metadata['crossword_title']
          = link_to notification.metadata['crossword_title'],
                    notification.metadata['team_path']
    .xw-notification__meta
      %time{ datetime: notification.created_at.iso8601 }
        = time_ago_in_words(notification.created_at)
        ago
    - if notification.notification_type == 'friend_request' && notification.read_at.nil?
      .xw-notification__actions
        = button_to 'Accept', accept_friend_requests_path(sender_id: notification.actor_id),
                    method: :post, class: 'xw-btn xw-btn--primary xw-btn--sm',
                    data: { turbo: false }
        = button_to 'Decline', reject_friend_requests_path(sender_id: notification.actor_id),
                    method: :delete, class: 'xw-btn xw-btn--ghost xw-btn--sm',
                    data: { turbo: false }
    - if notification.notification_type == 'puzzle_invite' && notification.metadata['team_path']
      .xw-notification__actions
        = link_to 'Join', notification.metadata['team_path'],
                  class: 'xw-btn xw-btn--primary xw-btn--sm'
```

**⚠️ Avatar guard (SHOULD-FIX #6):** Uses `actor.image.present?` check with fallback to `default_images/user.jpg`. This prevents errors when `ApplicationController.render` runs outside request context (ActionCable broadcast).

**⚠️ Accept/Decline buttons use `data: { turbo: false }` (SHOULD-FIX #5):** This forces a full redirect instead of Turbo Stream, giving clear visual feedback (page reloads showing the notification as read). The Turbo Stream approach requires targeting elements that only exist on the inbox page — unnecessarily complex for v1.

### Task 1.12b — Turbo Stream Templates

**File:** `app/views/notifications/mark_all_read.turbo_stream.erb`

```erb
<%= turbo_stream.replace "notifications-list" do %>
  <div id="notifications-list" class="xw-notifications__list">
    <% @current_user.notifications.includes(:actor).recent.each do |notification| %>
      <%= render partial: 'notifications/partials/notification',
                 locals: { notification: notification } %>
    <% end %>
  </div>
<% end %>
```

**File:** `app/views/notifications/mark_read.turbo_stream.erb`

```erb
<%= turbo_stream.replace "notification-#{@notification.id}" do %>
  <%= render partial: 'notifications/partials/notification',
             locals: { notification: @notification } %>
<% end %>
```

Wait — `mark_read` doesn't set `@notification`. Fix the controller:

In `NotificationsController#mark_read`, change the local var `notification` to `@notification`:
```ruby
def mark_read
  @notification = @current_user.notifications.find_by(id: params[:id])
  return head :not_found unless @notification
  @notification.update!(read_at: Time.current) if @notification.read_at.nil?
  # ...
end
```

### Task 1.13 — Notification CSS

**File:** `app/assets/stylesheets/_notifications.scss` (NEW)

```scss
// =============================================================================
// Notifications Inbox — .xw-notifications
// =============================================================================

.xw-notifications__header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: var(--space-4);
  margin-bottom: var(--space-6);
}

.xw-notifications__title {
  display: flex;
  align-items: center;
  gap: var(--space-2);
  font-family: var(--font-heading);
  font-size: var(--text-2xl);
  font-weight: var(--weight-semibold);
  color: var(--color-text);
  margin: 0;
}

.xw-notifications__list {
  display: flex;
  flex-direction: column;
  gap: var(--space-2);
}

.xw-notifications__empty {
  text-align: center;
  padding: var(--space-12) var(--space-4);
  color: var(--color-text-secondary);
  font-family: var(--font-body);
}

// Individual notification row
.xw-notification {
  display: flex;
  gap: var(--space-3);
  padding: var(--space-3) var(--space-4);
  border-radius: var(--radius-md);
  background-color: var(--color-surface);
  border: 1px solid var(--color-border);
  transition: background-color var(--duration-fast) var(--ease-out);
}

.xw-notification--unread {
  border-left: 3px solid var(--color-accent);
  background-color: var(--color-surface-alt);
}

.xw-notification__avatar-img {
  width: 2.5rem;
  height: 2.5rem;
  border-radius: var(--radius-full);
  object-fit: cover;
  flex-shrink: 0;
}

.xw-notification__body {
  flex: 1;
  min-width: 0;
}

.xw-notification__message {
  font-family: var(--font-body);
  font-size: var(--text-sm);
  color: var(--color-text);
  line-height: var(--leading-relaxed);

  a {
    font-weight: var(--weight-semibold);
    color: var(--color-accent);
    text-decoration: none;
    &:hover { text-decoration: underline; }
  }
}

.xw-notification__meta {
  font-family: var(--font-ui);
  font-size: var(--text-xs);
  color: var(--color-text-secondary);
  margin-top: var(--space-1);
}

.xw-notification__actions {
  display: flex;
  gap: var(--space-2);
  margin-top: var(--space-2);
}
```

**File:** `app/assets/stylesheets/application.scss` — add require after `_nav`:

```scss
 *= require _notifications
```

**⚠️ MUST-FIX #4:** Use `*= require` Sprockets directive, NOT `@import`. Do NOT add `@import 'design_tokens'` at top of `_notifications.scss` — CSS custom properties are globally available after `_design_tokens` is loaded.

### Task 1.14 — Tests (Phase 1)

**File:** `spec/models/notification_spec.rb`
- Validates presence of notification_type
- Validates inclusion (5 valid types)
- Cannot notify self
- `unread` scope returns only read_at: nil
- `recent` scope orders by created_at desc, limits to 50
- Belongs to user, actor, notifiable (optional)

**File:** `spec/services/notification_service_spec.rb`
- Creates notification with correct attributes
- Returns nil for self-notification (user == actor)
- Returns nil on duplicate (dedup index)
- Broadcasts to ActionCable (stub `ActionCable.server.broadcast`)
- Handles nil notifiable (friend_request type)

**File:** `spec/requests/notifications_spec.rb`
- `GET /notifications` requires login → redirects anonymous to `account_required_path`
- `GET /notifications` shows user's notifications
- `PATCH /notifications/:id/mark_read` sets read_at
- `PATCH /notifications/mark_all_read` sets read_at on all unread
- Mark read returns 404 for notifications belonging to other users

### Task 1.15 — Delete Dead ActionCable Files

Confirmed dead code. `team_funcs.js.erb` creates its own consumer (line 291). These files are never loaded.

**Delete:**
- `app/assets/javascripts/cable.js`
- `app/assets/javascripts/channels/chatrooms.js`

---

## Phase 2: Friend Request Flow (4 tasks)

### Task 2.1 — FriendRequestsController

**File:** `app/controllers/friend_requests_controller.rb`

```ruby
class FriendRequestsController < ApplicationController
  before_action :ensure_logged_in

  # POST /friend_requests
  def create
    recipient = User.find_by(id: params[:recipient_id])
    return head :not_found unless recipient
    return head :unprocessable_entity if recipient == @current_user
    return head :unprocessable_entity if @current_user.friends_with?(recipient)
    return head :unprocessable_entity if FriendRequest.where(sender_id: @current_user.id, recipient_id: recipient.id).exists?
    return head :unprocessable_entity if FriendRequest.where(sender_id: recipient.id, recipient_id: @current_user.id).exists?

    FriendRequest.create!(sender: @current_user, recipient: recipient)

    NotificationService.notify(
      user: recipient, actor: @current_user,
      type: 'friend_request'
    )

    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.replace(
        "friend-status-#{recipient.id}",
        partial: 'users/partials/friend_status',
        locals: { user: recipient, status: :pending_sent }
      )}
      format.html { redirect_to user_path(recipient) }
    end
  end

  # POST /friend_requests/accept
  def accept
    request = FriendRequest.find_by(sender_id: params[:sender_id], recipient_id: @current_user.id)
    return head :not_found unless request

    ActiveRecord::Base.transaction do
      Friendship.create!(user_id: request.sender_id, friend_id: request.recipient_id)
      # ⚠️ MUST-FIX #2: FriendRequest has id: false — destroy! would fail.
      FriendRequest.where(sender_id: request.sender_id, recipient_id: request.recipient_id).delete_all
    end

    # Notify the original sender that their request was accepted
    NotificationService.notify(
      user: User.find(request.sender_id), actor: @current_user,
      type: 'friend_accepted'
    )

    # Mark the friend_request notification as read
    Notification.where(user_id: @current_user.id, actor_id: params[:sender_id],
                       notification_type: 'friend_request')
                .unread.update_all(read_at: Time.current)

    respond_to do |format|
      format.html { redirect_to(params[:redirect_to] || notifications_path) }
    end
  end

  # DELETE /friend_requests/reject
  def reject
    # ⚠️ MUST-FIX #2: No id column — use composite key lookup + delete_all.
    FriendRequest.where(sender_id: params[:sender_id], recipient_id: @current_user.id).delete_all

    # Mark the friend_request notification as read
    Notification.where(user_id: @current_user.id, actor_id: params[:sender_id],
                       notification_type: 'friend_request')
                .unread.update_all(read_at: Time.current)

    respond_to do |format|
      format.html { redirect_to notifications_path }
    end
  end
end
```

**Key design decisions:**
- Accept/Reject use `data: { turbo: false }` in the notification partial → redirect, not Turbo Stream (simpler for v1)
- Accept/Reject mark the corresponding notification as read (Suggestion #7)
- `request` local var shadows the Rails `request` object — rename to `freq` or use carefully (only accessing `.sender_id`/`.recipient_id` which are known attributes)

### Task 2.2 — Profile Page Friend Button

**File:** `app/controllers/users_controller.rb` — in `show` action, replace `@is_friend` logic (lines 16-17) with:

```ruby
if @current_user && @current_user != @user
  if @current_user.friends_with?(@user)
    @friend_status = :friends
  elsif FriendRequest.where(sender_id: @current_user.id, recipient_id: @user.id).exists?
    @friend_status = :pending_sent
  elsif FriendRequest.where(sender_id: @user.id, recipient_id: @current_user.id).exists?
    @friend_status = :pending_received
  else
    @friend_status = :none
  end
end
```

**File:** `app/views/users/partials/_user.html.haml` — replace lines 11-17 (friend buttons section):

```haml
- if @current_user && (@current_user != @user)
  = turbo_frame_tag "friend-status-#{@user.id}" do
    = render partial: 'users/partials/friend_status',
             locals: { user: @user, status: @friend_status }
```

**File:** `app/views/users/partials/_friend_status.html.haml` (NEW)

```haml
- case status
- when :friends
  %span.xw-btn.xw-btn--success.xw-btn--sm
    = icon('check')
    Friends!
- when :pending_sent
  %span.xw-btn.xw-btn--ghost.xw-btn--sm{ disabled: true }
    = icon('clock', size: 16)
    Request Sent
- when :pending_received
  .xw-profile-hero__friend-actions
    = button_to 'Accept', accept_friend_requests_path(sender_id: user.id),
                method: :post, class: 'xw-btn xw-btn--primary xw-btn--sm'
    = button_to 'Decline', reject_friend_requests_path(sender_id: user.id),
                method: :delete, class: 'xw-btn xw-btn--ghost xw-btn--sm'
- when :none
  = button_to 'Add Friend', friend_requests_path(recipient_id: user.id),
              method: :post, class: 'xw-btn xw-btn--primary xw-btn--sm'
```

### Task 2.3 — Turbo Stream Template for Create

**File:** `app/views/friend_requests/create.turbo_stream.erb`

Already handled inline in controller (`turbo_stream.replace` with partial). No separate file needed unless we want to separate — keeping inline for simplicity.

### Task 2.4 — Friend Request Tests

**File:** `spec/requests/friend_requests_spec.rb`

Test cases:
- **create:** happy path (creates request, sends notification), already friends (422), self-request (422), duplicate request (422), reverse request exists (422), anonymous (redirect)
- **accept:** creates friendship, destroys request, sends friend_accepted notification, marks friend_request notification as read
- **reject:** destroys request, marks notification as read, no notification sent

---

## Phase 3: Comment Notifications (2 tasks)

### Task 3.1 — Hook into CommentsController

**File:** `app/controllers/comments_controller.rb`

**In `add_comment` action (after `@new_comment.save` succeeds):**

Current code (lines 11-16):
```ruby
if crossword.comments.where(user_id: @current_user.id).count < Comment::MAX_PER_CROSSWORD
  @new_comment = Comment.new(content: params[:content], crossword: crossword, user: @current_user)
  return head :unprocessable_entity unless @new_comment.save
else
  head :forbidden
end
```

Replace with:
```ruby
if crossword.comments.where(user_id: @current_user.id).count < Comment::MAX_PER_CROSSWORD
  @new_comment = Comment.new(content: params[:content], crossword: crossword, user: @current_user)
  if @new_comment.save
    if crossword.user && crossword.user != @current_user
      NotificationService.notify(
        user: crossword.user, actor: @current_user,
        type: 'comment_on_puzzle', notifiable: @new_comment,
        metadata: { crossword_id: crossword.id, crossword_title: crossword.title }
      )
    end
    # Falls through to implicit render of add_comment.turbo_stream.erb
  else
    return head :unprocessable_entity
  end
else
  head :forbidden
end
```

**⚠️ Suggestion #8:** Changed from guard-clause (`return ... unless save`) to if/else so the notification can fire in the success path before falling through to the implicit turbo_stream render. Verify manually that `add_comment.turbo_stream.erb` still renders correctly.

**In `reply` action (after `@base_comment.replies << @new_reply` and checking `persisted?`):**

Current code (lines 26-28):
```ruby
@new_reply = Comment.new(content: params[:content], user: @current_user)
@base_comment.replies << @new_reply
return head :unprocessable_entity unless @new_reply.persisted?
```

Replace with:
```ruby
@new_reply = Comment.new(content: params[:content], user: @current_user)
@base_comment.replies << @new_reply
return head :unprocessable_entity unless @new_reply.persisted?

if @base_comment.user && @base_comment.user != @current_user
  NotificationService.notify(
    user: @base_comment.user, actor: @current_user,
    type: 'comment_reply', notifiable: @new_reply,
    metadata: {
      crossword_id: @base_comment.base_crossword&.id,
      crossword_title: @base_comment.base_crossword&.title,
      comment_excerpt: @new_reply.content.truncate(80)
    }
  )
end
```

### Task 3.2 — Comment Notification Tests

Add to `spec/requests/comments_spec.rb`:
- Commenting on someone else's puzzle creates a notification
- Commenting on your own puzzle does NOT create a notification
- Replying to someone else's comment creates a notification
- Replying to your own comment does NOT create a notification (self-notification guard)

---

## Phase 4: Puzzle Invites (5 tasks)

### Task 4.1 — Friends API Endpoint

**File:** `app/controllers/api/users_controller.rb` — add `friends` action:

```ruby
# GET /api/users/friends
def friends
  return head :unauthorized unless @current_user

  render json: @current_user.friends.select(:id, :first_name, :last_name, :username, :image)
                             .map { |u| {
                               id: u.id,
                               username: u.username,
                               display_name: u.display_name,
                               avatar_url: u.image.present? ? u.image.search.url : ActionController::Base.helpers.asset_path('default_images/user.jpg')
                             }}
end
```

**File:** `config/routes.rb` — add to the API namespace:

```ruby
namespace :api, defaults: {format: :json} do
  # ... existing routes ...
  namespace :users do
    get '/' => :index
    get :search
    get :friends   # NEW
  end
end
```

### Task 4.2 — PuzzleInvitesController

**File:** `app/controllers/puzzle_invites_controller.rb`

```ruby
class PuzzleInvitesController < ApplicationController
  before_action :ensure_logged_in

  # POST /puzzle_invites
  def create
    solution = Solution.find_by(id: params[:solution_id])
    return head :not_found unless solution&.team?

    invitee = User.find_by(id: params[:user_id])
    return head :not_found unless invitee
    return head :unprocessable_entity unless @current_user.friends_with?(invitee)

    crossword = solution.crossword
    team_path = team_crossword_path(crossword, solution.key)

    NotificationService.notify(
      user: invitee, actor: @current_user,
      type: 'puzzle_invite', notifiable: solution,
      metadata: {
        crossword_id: crossword&.id,
        crossword_title: crossword&.title,
        team_path: team_path
      }
    )

    head :ok
  end
end
```

### Task 4.3 — Team Page Invite UI

**File:** `app/views/crosswords/partials/_team.html.haml` — add invite section inside the modal, after the URL copy row:

```haml
- if @current_user
  .team-modal__invite{ data: { controller: 'invite',
                                'invite-solution-id-value': @solution.id,
                                'invite-friends-url-value': api_users_friends_path } }
    %h3.team-modal__invite-heading
      = icon('user-plus', size: 18)
      Invite a Friend
    .team-modal__invite-body{ data: { 'invite-target': 'body' } }
      %button.xw-btn.xw-btn--ghost.xw-btn--sm{ type: 'button',
                                                  data: { action: 'invite#loadFriends' } }
        Load friends list
```

**File:** `app/assets/javascripts/controllers/invite_controller.js` (NEW)

```javascript
// Stimulus controller for inviting friends to team solve.
// Fetches friends list from API, renders dropdown, submits invite.
(function() {
  var InviteController = class extends Stimulus.Controller {
    static get targets() { return ['body']; }
    static get values() { return { solutionId: Number, friendsUrl: String }; }

    loadFriends() {
      var self = this;
      fetch(this.friendsUrlValue, {
        headers: { 'Accept': 'application/json' }
      })
      .then(function(r) { return r.json(); })
      .then(function(friends) {
        if (friends.length === 0) {
          self.bodyTarget.innerHTML = '<p class="xw-text-muted">No friends yet. Share the link above!</p>';
          return;
        }
        var html = '<div class="team-modal__friends-list">';
        friends.forEach(function(f) {
          html += '<button type="button" class="team-modal__friend-btn" ' +
                  'data-action="invite#sendInvite" data-user-id="' + f.id + '">' +
                  '<span class="team-modal__friend-name">' + self.escapeHtml(f.display_name) + '</span>' +
                  '<span class="team-modal__friend-username">@' + self.escapeHtml(f.username) + '</span>' +
                  '</button>';
        });
        html += '</div>';
        self.bodyTarget.innerHTML = html;
      })
      .catch(function() {
        self.bodyTarget.innerHTML = '<p class="xw-text-danger">Could not load friends.</p>';
      });
    }

    sendInvite(event) {
      var btn = event.currentTarget;
      var userId = btn.dataset.userId;
      var csrfToken = document.querySelector('meta[name="csrf-token"]').content;
      var self = this;

      btn.disabled = true;
      btn.textContent = 'Sending…';

      fetch('/puzzle_invites', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': csrfToken,
          'Accept': 'application/json'
        },
        body: JSON.stringify({
          solution_id: self.solutionIdValue,
          user_id: userId
        })
      })
      .then(function(r) {
        if (r.ok) {
          btn.textContent = 'Invited ✓';
          btn.classList.add('team-modal__friend-btn--invited');
        } else {
          btn.textContent = 'Failed';
          btn.disabled = false;
        }
      })
      .catch(function() {
        btn.textContent = 'Failed';
        btn.disabled = false;
      });
    }

    escapeHtml(str) {
      var div = document.createElement('div');
      div.textContent = str;
      return div.innerHTML;
    }
  };

  window.StimulusApp.register('invite', InviteController);
})();
```

### Task 4.4 — Routes

**File:** `config/routes.rb` — add after friend_requests:

```ruby
resources :puzzle_invites, only: [:create]
```

### Task 4.5 — Puzzle Invite Tests

**File:** `spec/requests/puzzle_invites_spec.rb`

Test cases:
- Happy path: creates notification for friend
- Not friends: returns 422
- Non-team solution: returns 404
- Nonexistent solution: returns 404
- Anonymous: redirect to account_required

---

## Verification After Each Phase

1. `bundle exec rspec` — all examples pass
2. **Phase 1:** Login → nav shows bell icon → click → `/notifications` → empty inbox. ActionCable connects in browser console (check WebSocket tab).
3. **Phase 2:** Visit another user's profile → "Add Friend" → click → "Request Sent". Login as other user → badge count updates → inbox shows friend request → Accept → both profiles show "Friends!"
4. **Phase 3:** Comment on someone else's puzzle → they see notification. Reply → they see notification. Own puzzle/comment → no notification.
5. **Phase 4:** Team page → "Invite a Friend" → pick friend → friend sees notification with "Join" link.

---

## Files Summary

### New Files (20)
| File | Phase |
|------|-------|
| `db/migrate/TIMESTAMP_create_notifications.rb` | 1 |
| `app/models/notification.rb` | 1 |
| `app/services/notification_service.rb` | 1 |
| `app/channels/notifications_channel.rb` | 1 |
| `app/assets/javascripts/notifications_channel.js` | 1 |
| `app/controllers/notifications_controller.rb` | 1 |
| `app/views/notifications/index.html.haml` | 1 |
| `app/views/notifications/partials/_notification.html.haml` | 1 |
| `app/views/notifications/mark_all_read.turbo_stream.erb` | 1 |
| `app/views/notifications/mark_read.turbo_stream.erb` | 1 |
| `app/assets/stylesheets/_notifications.scss` | 1 |
| `spec/factories/notification_factory.rb` | 1 |
| `spec/models/notification_spec.rb` | 1 |
| `spec/services/notification_service_spec.rb` | 1 |
| `spec/requests/notifications_spec.rb` | 1 |
| `app/controllers/friend_requests_controller.rb` | 2 |
| `app/views/users/partials/_friend_status.html.haml` | 2 |
| `spec/requests/friend_requests_spec.rb` | 2 |
| `app/controllers/puzzle_invites_controller.rb` | 4 |
| `app/assets/javascripts/controllers/invite_controller.js` | 4 |
| `spec/requests/puzzle_invites_spec.rb` | 4 |

### Modified Files (9)
| File | Phase | Change |
|------|-------|--------|
| `app/models/user.rb` | 1 | `has_many :notifications`, friend request associations |
| `app/controllers/application_controller.rb` | 1 | `load_unread_notification_count` before_action |
| `app/views/layouts/application.html.haml` | 1 | Conditional ActionCable + notifications JS |
| `app/views/layouts/partials/_nav.html.haml` | 1 | Bell icon, badge count, link to inbox |
| `app/assets/stylesheets/_nav.scss` | 1 | `.xw-badge` styles |
| `app/assets/stylesheets/application.scss` | 1 | `*= require _notifications` |
| `config/routes.rb` | 1,2,4 | Notification, friend_request, puzzle_invite routes |
| `app/views/users/partials/_user.html.haml` | 2 | Turbo Frame + friend_status partial |
| `app/controllers/users_controller.rb` | 2 | `@friend_status` in show action |
| `app/controllers/comments_controller.rb` | 3 | NotificationService calls |
| `app/controllers/api/users_controller.rb` | 4 | `friends` endpoint |
| `app/views/crosswords/partials/_team.html.haml` | 4 | Invite section in modal |

### Deleted Files (2)
| File | Phase |
|------|-------|
| `app/assets/javascripts/cable.js` | 1 |
| `app/assets/javascripts/channels/chatrooms.js` | 1 |
