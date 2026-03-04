# Notification System — Implementation Plan

## Overview

4-phase plan. Each phase is independently deployable. ~20 new files, ~9 modified files, 2 deleted files.

---

## Phase 1: Notification Backbone (13 tasks)

The foundation everything else plugs into. No notification-generating features yet.

### Task 1.1: Migration — `create_notifications`

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

    # Inbox listing: "all unread for this user, newest first"
    add_index :notifications, [:user_id, :read_at, :created_at]

    # Cleanup when notifiable is deleted
    add_index :notifications, [:notifiable_type, :notifiable_id]

    # Dedup guard: one notification per (user, actor, type, notifiable)
    add_index :notifications,
              [:user_id, :actor_id, :notification_type, :notifiable_type, :notifiable_id],
              unique: true,
              name: 'index_notifications_on_dedup'
  end
end
```

**Critical:** Use `t.integer` for `user_id` and `actor_id` (NOT `t.references`) because `users.id` is `integer`, not `bigint`. Foreign key type mismatch would cause silent query failures.

**Acceptance:** `rails db:migrate` succeeds. `rails db:rollback` succeeds. Schema shows `notifications` table with all 3 indexes.

---

### Task 1.2: Notification model

**File:** `app/models/notification.rb`

```ruby
class Notification < ApplicationRecord
  belongs_to :user, inverse_of: :notifications                        # recipient
  belongs_to :actor, class_name: 'User'                               # who triggered it
  belongs_to :notifiable, polymorphic: true, optional: true           # e.g. Comment, Solution

  VALID_TYPES = %w[
    friend_request friend_accepted
    puzzle_invite
    comment_on_puzzle comment_reply
  ].freeze

  validates :notification_type, presence: true, inclusion: { in: VALID_TYPES }
  validate :cannot_notify_self

  scope :unread,  -> { where(read_at: nil) }
  scope :read,    -> { where.not(read_at: nil) }
  scope :recent,  -> { order(created_at: :desc).limit(50) }

  def read?
    read_at.present?
  end

  def mark_read!
    update!(read_at: Time.current) unless read?
  end

  private

  def cannot_notify_self
    errors.add(:user_id, "can't notify yourself") if user_id == actor_id
  end
end
```

**Acceptance:** Model validations prevent self-notification and invalid types. Scopes return correct sets. `read?` and `mark_read!` work.

---

### Task 1.3: User model associations

**File:** `app/models/user.rb` — add these associations:

```ruby
has_many :notifications, inverse_of: :user, dependent: :destroy

has_many :sent_friend_requests, class_name: 'FriendRequest', foreign_key: :sender_id
has_many :received_friend_requests, class_name: 'FriendRequest', foreign_key: :recipient_id
```

**Note:** `sent_friend_requests` / `received_friend_requests` add semantic access. No `dependent: :destroy` — FriendRequest has no `id` column so Rails can't issue `DELETE FROM friend_requests WHERE id IN (...)`. The app cleans up friend requests explicitly during accept/reject.

**Acceptance:** `user.notifications` returns AR relation. `user.sent_friend_requests` and `user.received_friend_requests` work.

---

### Task 1.4: Notification factory

**File:** `spec/factories/notification_factory.rb`

```ruby
FactoryBot.define do
  factory :notification do
    user  { association(:user) }
    actor { association(:user) }
    notification_type { 'friend_request' }

    trait :friend_request do
      notification_type { 'friend_request' }
    end

    trait :friend_accepted do
      notification_type { 'friend_accepted' }
    end

    trait :comment_on_puzzle do
      notification_type { 'comment_on_puzzle' }
      notifiable { association(:comment) }
    end

    trait :comment_reply do
      notification_type { 'comment_reply' }
      notifiable { association(:comment) }
    end

    trait :puzzle_invite do
      notification_type { 'puzzle_invite' }
      notifiable { association(:solution) }
    end

    trait :read do
      read_at { Time.current }
    end
  end
end
```

---

### Task 1.5: NotificationService

**File:** `app/services/notification_service.rb`

Follows `CrosswordPublisher` pattern — class methods, no instance state.

```ruby
# Single entry point for creating notifications + broadcasting via ActionCable.
#
# Usage:
#   NotificationService.notify(
#     user: recipient, actor: sender,
#     type: 'comment_reply', notifiable: comment,
#     metadata: { crossword_title: 'Monday Mini' }
#   )
#
# Returns the Notification, or nil if self-notification or duplicate.
class NotificationService
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
    # Dedup index caught a duplicate — safe to ignore
    nil
  end

  def self.broadcast(notification)
    html = ApplicationController.render(
      partial: 'notifications/partials/notification',
      locals: { notification: notification }
    )

    unread_count = notification.user.notifications.unread.count

    ActionCable.server.broadcast(
      "notifications_#{notification.user_id}",
      {
        type: 'new_notification',
        html: html,
        unread_count: unread_count
      }
    )
  rescue StandardError => e
    # Don't let broadcast failures prevent notification creation
    Rails.logger.error("[NotificationService] broadcast failed: #{e.class} — #{e.message}")
  end
  private_class_method :broadcast
end
```

**Key decisions:**
- `ApplicationController.render` works outside request context (Rails 5+).
- Broadcast failure is non-fatal (rescued + logged).
- `RecordNotUnique` rescue is the dedup safety net.
- Returns `nil` for self-notification.

---

### Task 1.6: NotificationsChannel

**File:** `app/channels/notifications_channel.rb`

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

Follows `TeamsChannel` pattern. `current_user` comes from `ApplicationCable::Connection#find_verified_user` (returns nil for anonymous).

---

### Task 1.7: ActionCable JS loading + notifications_channel.js

**File: `app/views/layouts/application.html.haml`** — add after `= javascript_include_tag "application"` (line 11):

```haml
    - if is_logged_in?
      = javascript_include_tag 'actioncable'
      = javascript_include_tag 'notifications_channel'
```

**Why conditional:** Anonymous users never get notifications. Team partial's existing `= javascript_include_tag 'actioncable'` becomes redundant for logged-in users but harmless (browser caches).

**File: `app/assets/javascripts/notifications_channel.js`** — new file:

```javascript
// Subscribes to the current user's notification channel.
// Updates the nav badge count and optionally prepends notifications to the inbox.
// Loaded conditionally for logged-in users only (see application.html.haml).

(function() {
  var consumer = ActionCable.createConsumer();

  consumer.subscriptions.create('NotificationsChannel', {
    received: function(data) {
      if (data.type === 'new_notification') {
        updateBadge(data.unread_count);
        prependToInbox(data.html);
      } else if (data.type === 'badge_update') {
        updateBadge(data.unread_count);
      }
    }
  });

  function updateBadge(count) {
    var navMail = document.getElementById('nav-mail');
    if (!navMail) return;

    var badge = navMail.querySelector('.xw-badge');

    if (count > 0) {
      navMail.classList.add('unread');
      if (!badge) {
        badge = document.createElement('span');
        badge.className = 'xw-badge';
        navMail.appendChild(badge);
      }
      badge.textContent = count > 99 ? '99+' : count;
    } else {
      navMail.classList.remove('unread');
      if (badge) badge.remove();
    }
  }

  function prependToInbox(html) {
    var list = document.getElementById('notifications-list');
    if (!list) return;

    var emptyState = list.querySelector('.xw-notifications__empty');
    if (emptyState) emptyState.remove();

    list.insertAdjacentHTML('afterbegin', html);
  }

  // On page load, set initial badge from server-rendered data attribute
  document.addEventListener('DOMContentLoaded', function() {
    var navMail = document.getElementById('nav-mail');
    if (navMail) {
      var initialCount = parseInt(navMail.dataset.unreadCount || '0', 10);
      if (initialCount > 0) updateBadge(initialCount);
    }
  });
})();
```

---

### Task 1.8: Nav badge + link

**File: `app/views/layouts/partials/_nav.html.haml`** — replace lines 64-69:

```haml
        / Notifications — #nav-mail preserved (CSS unread pulse animation)
        - if is_logged_in?
          .xw-nav__item#nav-mail{ data: { 'unread-count' => @unread_notification_count } }
            = link_to notifications_path, class: 'xw-nav__icon-btn',
                      data: { xw_tooltip: 'Notifications' } do
              = icon('bell')
              - if @unread_notification_count > 0
                %span.xw-badge= @unread_notification_count > 99 ? '99+' : @unread_notification_count
```

**Note:** Changed icon from `mail` to `bell` — more standard for notifications. `#nav-mail` ID preserved for CSS pulse animation. `data-unread-count` attribute read by JS on page load.

**Verify `bell.svg` exists:** Check `app/assets/images/icons/` for `bell.svg`. If not present, use Lucide bell icon or keep `mail`. Builder should check.

**File: `app/controllers/application_controller.rb`** — add:

```ruby
before_action :load_unread_notification_count

def load_unread_notification_count
  @unread_notification_count = @current_user&.notifications&.unread&.count || 0
end
```

Single `COUNT(*)` with index — sub-millisecond. For anonymous users: `@current_user` is nil → returns 0 immediately.

---

### Task 1.9: Badge CSS

**File: `app/assets/stylesheets/_nav.scss`** — add after the `@keyframes xw-unread-pulse` block (after line 175):

```scss
// Notification badge — red circle with count, positioned on the nav icon
.xw-badge {
  position: absolute;
  top: 2px;
  right: 2px;
  min-width: 1.1rem;
  height: 1.1rem;
  padding: 0 var(--space-1);
  background-color: var(--color-danger);
  color: #fff;
  font-family: var(--font-ui);
  font-size: 0.65rem;
  font-weight: var(--weight-semibold);
  line-height: 1.1rem;
  text-align: center;
  border-radius: var(--radius-full);
  pointer-events: none;
}
```

`.xw-nav__item` is already `position: relative` (line 133) — `position: absolute` on `.xw-badge` positions within the nav item.

---

### Task 1.10: NotificationsController + views

**File: `app/controllers/notifications_controller.rb`**

```ruby
class NotificationsController < ApplicationController
  before_action :ensure_logged_in

  # GET /notifications
  def index
    @notifications = @current_user.notifications
                                  .includes(:actor)
                                  .recent
  end

  # PATCH /notifications/:id/read
  def mark_read
    notification = @current_user.notifications.find_by(id: params[:id])
    return head :not_found unless notification
    notification.mark_read!
    head :ok
  end

  # PATCH /notifications/read_all
  def mark_all_read
    @current_user.notifications.unread.update_all(read_at: Time.current)
    redirect_to notifications_path
  end
end
```

**Key decisions:**
- `.includes(:actor)` only — no eager-load of polymorphic `notifiable`. Display text from `metadata` jsonb.
- `mark_all_read` redirects back to index (simple v1). Turbo Stream version deferred.
- `mark_read` scoped to `@current_user.notifications` — prevents cross-user access.

**File: `config/routes.rb`** — add:

```ruby
resources :notifications, only: [:index] do
  member do
    patch :mark_read
  end
  collection do
    patch :mark_all_read
  end
end
```

---

### Task 1.11: Inbox views + notification partial

**File: `app/views/notifications/index.html.haml`**

```haml
- title 'Notifications'

= render layout: 'layouts/partials/topper_stopper', locals: { columns_class: 'xw-md-center-8' } do
  .xw-notifications
    .xw-notifications__header
      %h1.xw-notifications__title
        = icon('bell')
        Notifications
      - if @notifications.any? { |n| !n.read? }
        = button_to mark_all_read_notifications_path, method: :patch,
                    class: 'xw-btn xw-btn--ghost xw-btn--sm' do
          = icon('check-check')
          Mark all read

    #notifications-list.xw-notifications__list
      - if @notifications.any?
        - @notifications.each do |notification|
          = render partial: 'notifications/partials/notification',
                   locals: { notification: notification }
      - else
        %p.xw-notifications__empty No notifications yet.
```

**File: `app/views/notifications/partials/_notification.html.haml`**

```haml
-# Single notification row. Expects `notification` local with actor preloaded.
-# Display text from metadata jsonb — no extra queries for notifiable.

- actor = notification.actor
- meta = (notification.metadata || {}).symbolize_keys

%article.xw-notification{ class: ('xw-notification--unread' unless notification.read?),
                          id: "notification-#{notification.id}" }
  .xw-notification__avatar
    = image_tag actor.image.search.url, alt: actor.display_name, class: 'xw-notification__avatar-img'

  .xw-notification__body
    .xw-notification__message
      %strong= actor.display_name
      - case notification.notification_type
      - when 'friend_request'
        sent you a friend request.
      - when 'friend_accepted'
        accepted your friend request!
      - when 'puzzle_invite'
        invited you to team-solve
        - if meta[:crossword_title].present?
          %em= meta[:crossword_title]
      - when 'comment_on_puzzle'
        commented on
        - if meta[:crossword_title].present?
          %em= meta[:crossword_title]
      - when 'comment_reply'
        replied to your comment
        - if meta[:comment_excerpt].present?
          %span.xw-notification__excerpt= "\"#{meta[:comment_excerpt]}\""
    %time.xw-notification__time{ datetime: notification.created_at.iso8601 }
      = time_ago_in_words(notification.created_at)
      ago

  .xw-notification__actions
    - case notification.notification_type
    - when 'friend_request'
      = button_to 'Accept', accept_friend_requests_path(sender_id: notification.actor_id),
                  method: :post, class: 'xw-btn xw-btn--sm xw-btn--primary'
      = button_to 'Decline', reject_friend_requests_path(sender_id: notification.actor_id),
                  method: :delete, class: 'xw-btn xw-btn--sm xw-btn--ghost'
    - when 'puzzle_invite'
      - if meta[:team_path].present?
        = link_to 'Join', meta[:team_path], class: 'xw-btn xw-btn--sm xw-btn--primary'
    - when 'comment_on_puzzle', 'comment_reply'
      - if meta[:crossword_id].present?
        = link_to 'View', crossword_path(meta[:crossword_id]), class: 'xw-btn xw-btn--sm xw-btn--ghost'
```

**Note on `accept_friend_requests_path` / `reject_friend_requests_path`:** These won't exist until Phase 2. The partial renders them but they won't be triggered until friend request notifications exist, which also requires Phase 2. No runtime error — HAML generates the HTML but the buttons won't appear until Phase 2 creates `friend_request` type notifications. **Builder: ensure the route helper names match what the partial expects. If routes aren't defined yet, the partial will raise `NoMethodError` during rendering. Either:**
1. Wrap friend_request actions in `- if defined?(accept_friend_requests_path)` guard (ugly), OR
2. Add the friend_request routes in Phase 1 (even without the controller — just leave them orphaned until Phase 2), OR
3. **Recommended:** Add Phase 2 routes in Phase 1 since routes are cheap. The controller doesn't need to exist — routes without controllers just 404.

---

### Task 1.12: Notification CSS

**File: `app/assets/stylesheets/_notifications.scss`** — new file:

```scss
@import 'design_tokens';

.xw-notifications {
  max-width: 40rem;
  margin: 0 auto;
}

.xw-notifications__header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: var(--space-4);
}

.xw-notifications__title {
  font-family: var(--font-heading);
  font-size: var(--text-xl);
  font-weight: var(--weight-semibold);
  color: var(--color-text);
  display: flex;
  align-items: center;
  gap: var(--space-2);
  margin: 0;
}

.xw-notifications__empty {
  text-align: center;
  color: var(--color-text-secondary);
  font-family: var(--font-body);
  padding: var(--space-8) 0;
}

.xw-notification {
  display: flex;
  align-items: flex-start;
  gap: var(--space-3);
  padding: var(--space-3) var(--space-4);
  border-bottom: 1px solid var(--color-border);
  transition: background-color var(--duration-fast) var(--ease-out);

  &:last-child { border-bottom: none; }
  &:hover { background-color: var(--color-surface-alt); }
}

.xw-notification--unread {
  background-color: var(--color-surface-alt);
  border-left: 3px solid var(--color-accent);
  padding-left: calc(var(--space-4) - 3px);
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
  line-height: 1.4;
}

.xw-notification__excerpt {
  color: var(--color-text-secondary);
  font-style: italic;
}

.xw-notification__time {
  display: block;
  font-family: var(--font-ui);
  font-size: var(--text-xs);
  color: var(--color-text-muted);
  margin-top: var(--space-1);
}

.xw-notification__actions {
  display: flex;
  gap: var(--space-2);
  align-items: center;
  flex-shrink: 0;
}
```

**Builder:** Find where SCSS partials are imported (likely in `application.css.scss` or `crossword.scss.erb`) and add `@import 'notifications';`.

---

### Task 1.13: Phase 1 tests

**File: `spec/models/notification_spec.rb`**

```ruby
RSpec.describe Notification, type: :model do
  describe 'validations' do
    it 'is valid with valid attributes' do
      notification = build(:notification)
      expect(notification).to be_valid
    end

    it 'requires notification_type' do
      notification = build(:notification, notification_type: nil)
      expect(notification).not_to be_valid
    end

    it 'requires notification_type to be in VALID_TYPES' do
      notification = build(:notification, notification_type: 'invalid_type')
      expect(notification).not_to be_valid
    end

    it 'prevents self-notification' do
      user = create(:user)
      notification = build(:notification, user: user, actor: user)
      expect(notification).not_to be_valid
      expect(notification.errors[:user_id]).to include("can't notify yourself")
    end
  end

  describe 'scopes' do
    let(:user) { create(:user) }
    let(:actor) { create(:user) }

    it '.unread returns notifications with nil read_at' do
      unread = create(:notification, user: user, actor: actor)
      create(:notification, :read, user: user, actor: create(:user))
      expect(Notification.unread).to eq [unread]
    end

    it '.recent returns newest first, limited to 50' do
      notifications = 3.times.map do |i|
        create(:notification, user: user, actor: create(:user),
               notification_type: 'friend_request',
               created_at: i.days.ago)
      end
      expect(Notification.recent.first).to eq notifications.first
    end
  end

  describe '#mark_read!' do
    it 'sets read_at to current time' do
      notification = create(:notification)
      expect(notification.read_at).to be_nil
      notification.mark_read!
      expect(notification.read_at).to be_present
    end

    it 'does not re-update if already read' do
      notification = create(:notification, :read)
      original_read_at = notification.read_at
      notification.mark_read!
      expect(notification.read_at).to eq original_read_at
    end
  end
end
```

**File: `spec/services/notification_service_spec.rb`**

```ruby
RSpec.describe NotificationService do
  let(:user) { create(:user) }
  let(:actor) { create(:user) }

  before do
    allow(ActionCable.server).to receive(:broadcast)
    allow(ApplicationController).to receive(:render).and_return('<div>notification</div>')
  end

  describe '.notify' do
    it 'creates a notification' do
      expect {
        NotificationService.notify(user: user, actor: actor, type: 'friend_request')
      }.to change(Notification, :count).by(1)
    end

    it 'returns the created notification' do
      result = NotificationService.notify(user: user, actor: actor, type: 'friend_request')
      expect(result).to be_a(Notification)
      expect(result).to be_persisted
    end

    it 'returns nil for self-notification' do
      result = NotificationService.notify(user: user, actor: user, type: 'friend_request')
      expect(result).to be_nil
    end

    it 'does not create a notification for self-notification' do
      expect {
        NotificationService.notify(user: user, actor: user, type: 'friend_request')
      }.not_to change(Notification, :count)
    end

    it 'stores metadata' do
      notification = NotificationService.notify(
        user: user, actor: actor, type: 'comment_on_puzzle',
        metadata: { crossword_title: 'Monday Mini' }
      )
      expect(notification.metadata['crossword_title']).to eq 'Monday Mini'
    end

    it 'silently swallows duplicate notifications' do
      NotificationService.notify(user: user, actor: actor, type: 'friend_request')
      expect {
        NotificationService.notify(user: user, actor: actor, type: 'friend_request')
      }.not_to change(Notification, :count)
    end

    it 'broadcasts to the user channel' do
      NotificationService.notify(user: user, actor: actor, type: 'friend_request')
      expect(ActionCable.server).to have_received(:broadcast).with(
        "notifications_#{user.id}",
        hash_including(type: 'new_notification')
      )
    end
  end
end
```

**File: `spec/requests/notifications_spec.rb`**

```ruby
RSpec.describe 'Notifications', type: :request do
  let(:user)  { create(:user, :with_test_password) }
  let(:actor) { create(:user) }

  # Stub ActionCable for all notification tests
  before do
    allow(ActionCable.server).to receive(:broadcast)
  end

  describe 'GET /notifications' do
    it 'redirects anonymous users' do
      get '/notifications'
      expect(response).to redirect_to(account_required_path(redirect: '/notifications'))
    end

    it 'renders the inbox for logged-in users' do
      log_in_as(user)
      get '/notifications'
      expect(response).to have_http_status(:ok)
    end

    it 'shows notifications for the current user' do
      create(:notification, user: user, actor: actor)
      log_in_as(user)
      get '/notifications'
      expect(response.body).to include(actor.display_name)
    end
  end

  describe 'PATCH /notifications/:id/read' do
    it 'marks a notification as read' do
      notification = create(:notification, user: user, actor: actor)
      log_in_as(user)
      patch mark_read_notification_path(notification)
      expect(notification.reload.read_at).to be_present
    end

    it 'returns 404 for another user notification' do
      other = create(:user)
      notification = create(:notification, user: other, actor: actor)
      log_in_as(user)
      patch mark_read_notification_path(notification)
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'PATCH /notifications/read_all' do
    it 'marks all unread notifications as read' do
      create(:notification, user: user, actor: actor)
      create(:notification, user: user, actor: create(:user), notification_type: 'friend_accepted')
      log_in_as(user)
      patch mark_all_read_notifications_path
      expect(user.notifications.unread.count).to eq 0
    end
  end
end
```

---

### Task 1.14: Delete dead ActionCable files

**Files to delete:**
- `app/assets/javascripts/cable.js`
- `app/assets/javascripts/channels/chatrooms.js`
- `app/assets/javascripts/channels/` directory (empty after deletion)

**Reason:** Confirmed dead code. `team_funcs.js.erb` creates its own consumer. `cable.js` creates `App.cable` which nothing references. `chatrooms.js` is a manifest requiring `cable.js` and nothing else.

---

## Phase 2: Friend Request Flow (4 tasks)

### Task 2.1: FriendRequestsController

**File: `app/controllers/friend_requests_controller.rb`**

```ruby
class FriendRequestsController < ApplicationController
  before_action :ensure_logged_in

  # POST /friend_requests
  def create
    recipient = User.find_by(id: params[:recipient_id])
    return head :not_found unless recipient
    return head :unprocessable_entity if recipient == @current_user
    return head :conflict if @current_user.friends_with?(recipient)
    return head :conflict if FriendRequest.exists?(sender_id: @current_user.id, recipient_id: recipient.id)
    return head :conflict if FriendRequest.exists?(sender_id: recipient.id, recipient_id: @current_user.id)

    FriendRequest.create!(sender_id: @current_user.id, recipient_id: recipient.id)

    NotificationService.notify(
      user: recipient, actor: @current_user,
      type: 'friend_request',
      metadata: { sender_username: @current_user.username }
    )

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to user_path(recipient) }
    end
  end

  # POST /friend_requests/accept
  def accept
    request = FriendRequest.find_by(sender_id: params[:sender_id], recipient_id: @current_user.id)
    return head :not_found unless request

    ActiveRecord::Base.transaction do
      Friendship.create!(user_id: request.sender_id, friend_id: request.recipient_id)
      request.destroy!
    end

    sender = User.find_by(id: params[:sender_id])
    if sender
      NotificationService.notify(
        user: sender, actor: @current_user,
        type: 'friend_accepted',
        metadata: { accepter_username: @current_user.username }
      )
    end

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to notifications_path }
    end
  end

  # DELETE /friend_requests/reject
  def reject
    request = FriendRequest.find_by(sender_id: params[:sender_id], recipient_id: @current_user.id)
    return head :not_found unless request
    request.destroy!
    redirect_to notifications_path
  end
end
```

**Critical:** `FriendRequest` has no `id` column. All lookups by `(sender_id, recipient_id)`.

---

### Task 2.2: Routes

**File: `config/routes.rb`** — add:

```ruby
resources :friend_requests, only: [:create] do
  collection do
    post :accept
    delete :reject
  end
end
```

**Note:** Add these in Phase 1 if the notification partial references the route helpers. See Task 1.11 note.

---

### Task 2.3: Profile page friend button

**File: `app/controllers/users_controller.rb`** — modify `show` action. Replace the existing `@is_friend` logic (lines 16-17):

```ruby
if @current_user && @current_user != @user
  @is_friend = @current_user.friends_with?(@user)
  @friend_request_sent = !@is_friend && FriendRequest.exists?(
    sender_id: @current_user.id, recipient_id: @user.id
  )
  @friend_request_received = !@is_friend && FriendRequest.exists?(
    sender_id: @user.id, recipient_id: @current_user.id
  )
else
  @is_friend = false
  @friend_request_sent = false
  @friend_request_received = false
end
```

**File: `app/views/users/partials/_user.html.haml`** — replace lines 11-17:

```haml
      - if @current_user && (@current_user != @user)
        = turbo_frame_tag "friend-status-#{@user.id}" do
          - if @is_friend
            %span.xw-btn.xw-btn--success.xw-btn--sm
              = icon('check')
              Friends!
          - elsif @friend_request_sent
            %span.xw-btn.xw-btn--ghost.xw-btn--sm{ disabled: true }
              = icon('clock')
              Request Sent
          - elsif @friend_request_received
            .xw-profile-hero__friend-actions
              = button_to 'Accept', accept_friend_requests_path(sender_id: @user.id),
                          method: :post, class: 'xw-btn xw-btn--sm xw-btn--primary'
              = button_to 'Decline', reject_friend_requests_path(sender_id: @user.id),
                          method: :delete, class: 'xw-btn xw-btn--sm xw-btn--ghost'
          - else
            = button_to 'Add Friend', friend_requests_path(recipient_id: @user.id),
                        method: :post, class: 'xw-btn xw-btn--sm xw-btn--primary'
```

**File: `app/views/friend_requests/create.turbo_stream.erb`**

```erb
<turbo-stream action="replace" target="friend-status-<%= params[:recipient_id] %>">
  <template>
    <turbo-frame id="friend-status-<%= params[:recipient_id] %>">
      <span class="xw-btn xw-btn--ghost xw-btn--sm" disabled>
        <%= icon('clock') %> Request Sent
      </span>
    </turbo-frame>
  </template>
</turbo-stream>
```

**File: `app/views/friend_requests/accept.turbo_stream.erb`**

```erb
<turbo-stream action="replace" target="friend-status-<%= params[:sender_id] %>">
  <template>
    <turbo-frame id="friend-status-<%= params[:sender_id] %>">
      <span class="xw-btn xw-btn--success xw-btn--sm">
        <%= icon('check') %> Friends!
      </span>
    </turbo-frame>
  </template>
</turbo-stream>
```

---

### Task 2.4: Friend request tests

**File: `spec/requests/friend_requests_spec.rb`**

```ruby
RSpec.describe 'FriendRequests', type: :request do
  let(:user)  { create(:user, :with_test_password) }
  let(:other) { create(:user) }

  before do
    allow(ActionCable.server).to receive(:broadcast)
    allow(ApplicationController).to receive(:render).and_call_original
  end

  describe 'POST /friend_requests' do
    before { log_in_as(user) }

    it 'creates a friend request' do
      expect {
        post friend_requests_path, params: { recipient_id: other.id }
      }.to change(FriendRequest, :count).by(1)
    end

    it 'creates a notification for the recipient' do
      expect {
        post friend_requests_path, params: { recipient_id: other.id }
      }.to change(Notification, :count).by(1)

      notification = Notification.last
      expect(notification.user).to eq other
      expect(notification.actor).to eq user
      expect(notification.notification_type).to eq 'friend_request'
    end

    it 'rejects self-request' do
      post friend_requests_path, params: { recipient_id: user.id }
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it 'rejects if already friends' do
      Friendship.create!(user_id: user.id, friend_id: other.id)
      post friend_requests_path, params: { recipient_id: other.id }
      expect(response).to have_http_status(:conflict)
    end

    it 'rejects duplicate request' do
      FriendRequest.create!(sender_id: user.id, recipient_id: other.id)
      post friend_requests_path, params: { recipient_id: other.id }
      expect(response).to have_http_status(:conflict)
    end

    it 'rejects if reverse request exists' do
      FriendRequest.create!(sender_id: other.id, recipient_id: user.id)
      post friend_requests_path, params: { recipient_id: other.id }
      expect(response).to have_http_status(:conflict)
    end
  end

  describe 'POST /friend_requests/accept' do
    before do
      FriendRequest.create!(sender_id: other.id, recipient_id: user.id)
      log_in_as(user)
    end

    it 'creates a friendship and destroys the request' do
      expect {
        post accept_friend_requests_path, params: { sender_id: other.id }
      }.to change(Friendship, :count).by(1)
        .and change(FriendRequest, :count).by(-1)
    end

    it 'sends a friend_accepted notification to the sender' do
      post accept_friend_requests_path, params: { sender_id: other.id }
      notification = Notification.find_by(notification_type: 'friend_accepted')
      expect(notification.user).to eq other
      expect(notification.actor).to eq user
    end

    it 'returns 404 for nonexistent request' do
      post accept_friend_requests_path, params: { sender_id: 99999 }
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'DELETE /friend_requests/reject' do
    before do
      FriendRequest.create!(sender_id: other.id, recipient_id: user.id)
      log_in_as(user)
    end

    it 'destroys the request' do
      expect {
        delete reject_friend_requests_path, params: { sender_id: other.id }
      }.to change(FriendRequest, :count).by(-1)
    end

    it 'does not create a notification' do
      expect {
        delete reject_friend_requests_path, params: { sender_id: other.id }
      }.not_to change(Notification, :count)
    end
  end
end
```

---

## Phase 3: Comment Notifications (2 tasks)

### Task 3.1: Hook into CommentsController

**File: `app/controllers/comments_controller.rb`**

Restructure `add_comment` to handle notification after save:

```ruby
def add_comment
  return head :unauthorized unless @current_user

  crossword = Crossword.find_by(id: params[:id])
  return head :not_found unless crossword
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
    else
      return head :unprocessable_entity
    end
  else
    head :forbidden
  end
end
```

Restructure `reply` similarly:

```ruby
def reply
  @base_comment = @comment
  return head :unauthorized unless @current_user
  return head :unprocessable_entity if @base_comment.base_comment_id.present?

  @new_reply = Comment.new(content: params[:content], user: @current_user)
  @base_comment.replies << @new_reply
  if @new_reply.persisted?
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
  else
    return head :unprocessable_entity
  end
end
```

**Note on existing `add_comment` structure:** Current code uses `return head :unprocessable_entity unless @new_comment.save` — a guard-clause style. The restructured version uses `if/else` to accommodate the notification call between save and the implicit render. Builder should verify the implicit render still works (the `add_comment.turbo_stream.erb` template).

---

### Task 3.2: Comment notification tests

**File: `spec/requests/comments_spec.rb`** — add new describe blocks:

```ruby
describe 'POST /comments/:id/add (comment notifications)' do
  let(:puzzle_owner) { create(:user) }
  let(:crossword) { create(:crossword, :smaller, user: puzzle_owner) }
  let(:commenter) { create(:user, :with_test_password) }

  before do
    allow(ActionCable.server).to receive(:broadcast)
    log_in_as(commenter)
  end

  it 'notifies the puzzle owner when someone comments' do
    expect {
      post "/comments/#{crossword.id}/add",
           params: { content: 'Great puzzle!' },
           headers: { 'Accept' => Mime[:turbo_stream].to_s }
    }.to change(Notification, :count).by(1)

    notification = Notification.last
    expect(notification.user).to eq puzzle_owner
    expect(notification.notification_type).to eq 'comment_on_puzzle'
  end

  it 'does not notify when commenting on own puzzle' do
    own_crossword = create(:crossword, :smaller, user: commenter)
    expect {
      post "/comments/#{own_crossword.id}/add",
           params: { content: 'My own comment' },
           headers: { 'Accept' => Mime[:turbo_stream].to_s }
    }.not_to change(Notification, :count)
  end
end

describe 'POST /comments/:id/reply (reply notifications)' do
  let(:comment_author) { create(:user) }
  let(:crossword) { create(:crossword, :smaller) }
  let(:base_comment) { Comment.create!(content: 'Original', user: comment_author, crossword: crossword) }
  let(:replier) { create(:user, :with_test_password) }

  before do
    allow(ActionCable.server).to receive(:broadcast)
    log_in_as(replier)
  end

  it 'notifies the parent comment author on reply' do
    expect {
      post "/comments/#{base_comment.id}/reply",
           params: { content: 'Nice insight!' },
           headers: { 'Accept' => Mime[:turbo_stream].to_s }
    }.to change(Notification, :count).by(1)

    notification = Notification.last
    expect(notification.user).to eq comment_author
    expect(notification.notification_type).to eq 'comment_reply'
  end

  it 'does not notify when replying to own comment' do
    own_comment = Comment.create!(content: 'My comment', user: replier, crossword: crossword)
    expect {
      post "/comments/#{own_comment.id}/reply",
           params: { content: 'Self-reply' },
           headers: { 'Accept' => Mime[:turbo_stream].to_s }
    }.not_to change(Notification, :count)
  end
end
```

---

## Phase 4: Puzzle Invites (5 tasks)

### Task 4.1: Friends API endpoint

**File: `app/controllers/api/users_controller.rb`** — add:

```ruby
# GET /api/users/friends
def friends
  return head :unauthorized unless @current_user

  friends_list = @current_user.friends.select(:id, :first_name, :last_name, :username, :image)
  render json: friends_list.map { |f|
    {
      id: f.id,
      username: f.username,
      display_name: f.display_name,
      avatar_url: f.image.search.url
    }
  }
end
```

**File: `config/routes.rb`** — update API users namespace:

```ruby
namespace :users do
  get '/' => :index
  get :search
  get :friends
end
```

---

### Task 4.2: PuzzleInvitesController

**File: `app/controllers/puzzle_invites_controller.rb`**

```ruby
class PuzzleInvitesController < ApplicationController
  before_action :ensure_logged_in

  # POST /puzzle_invites
  def create
    solution = Solution.find_by(id: params[:solution_id])
    return head :not_found unless solution&.team?

    invitee = User.find_by(id: params[:invitee_id])
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

    respond_to do |format|
      format.json { render json: { success: true } }
      format.html { redirect_back fallback_location: root_path }
    end
  end
end
```

---

### Task 4.3: Team page invite UI

**File: `app/views/crosswords/partials/_team.html.haml`** — add after `%p.team-modal__footnote` (line 24):

```haml
  - if @current_user
    .team-modal__invite{ data: { controller: 'invite', 'invite-solution-id-value' => @solution.id } }
      %h3.team-modal__invite-heading
        = icon('user-plus')
        Invite a Friend
      .team-modal__invite-body{ data: { 'invite-target' => 'container' } }
        %button.xw-btn.xw-btn--sm.xw-btn--primary{ type: 'button',
                data: { action: 'invite#loadFriends' } }
          Load friends list
      %p.team-modal__invite-status{ data: { 'invite-target' => 'status' } }
```

**File: `app/assets/javascripts/controllers/invite_controller.js`** — new Stimulus controller following existing pattern:

```javascript
class InviteController extends Stimulus.Controller {
  loadFriends() {
    var container = this.containerTarget;
    var self = this;

    container.innerHTML = '<span class="xw-text-muted">Loading...</span>';

    fetch('/api/users/friends', { headers: { 'Accept': 'application/json' } })
    .then(function(response) { return response.json(); })
    .then(function(friends) {
      if (friends.length === 0) {
        container.innerHTML = '<span class="xw-text-muted">No friends yet!</span>';
        return;
      }
      var html = '<select class="xw-select" data-invite-target="select" data-action="change->invite#sendInvite">';
      html += '<option value="">Choose a friend…</option>';
      friends.forEach(function(f) {
        html += '<option value="' + f.id + '">' + f.display_name + ' (@' + f.username + ')</option>';
      });
      html += '</select>';
      container.innerHTML = html;
    })
    .catch(function() {
      container.innerHTML = '<span class="xw-text-muted">Could not load friends.</span>';
    });
  }

  sendInvite() {
    var select = this.selectTarget;
    var inviteeId = select.value;
    if (!inviteeId) return;

    var solutionId = this.element.dataset.inviteSolutionIdValue;
    var statusEl = this.statusTarget;
    var csrfToken = document.querySelector('meta[name="csrf-token"]').getAttribute('content');

    fetch('/puzzle_invites', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'X-CSRF-Token': csrfToken
      },
      body: JSON.stringify({ solution_id: solutionId, invitee_id: inviteeId })
    })
    .then(function(response) {
      if (response.ok) {
        var selectedText = select.options[select.selectedIndex].text;
        statusEl.textContent = 'Invite sent to ' + selectedText + '!';
        statusEl.className = 'team-modal__invite-status team-modal__invite-status--success';
        select.remove(select.selectedIndex);
        select.selectedIndex = 0;
      } else {
        statusEl.textContent = 'Could not send invite.';
        statusEl.className = 'team-modal__invite-status team-modal__invite-status--error';
      }
    })
    .catch(function() {
      statusEl.textContent = 'Network error. Please try again.';
    });
  }
}
InviteController.targets = ['container', 'select', 'status'];
window.StimulusApp.register('invite', InviteController);
```

---

### Task 4.4: Routes

**File: `config/routes.rb`** — add:

```ruby
resources :puzzle_invites, only: [:create]
```

---

### Task 4.5: Puzzle invite tests

**File: `spec/requests/puzzle_invites_spec.rb`**

```ruby
RSpec.describe 'PuzzleInvites', type: :request do
  let(:user)      { create(:user, :with_test_password) }
  let(:friend)    { create(:user) }
  let(:crossword) { create(:crossword, :smaller) }
  let(:solution)  { create(:solution, crossword: crossword, user: user, team: true) }

  before do
    Friendship.create!(user_id: user.id, friend_id: friend.id)
    allow(ActionCable.server).to receive(:broadcast)
    log_in_as(user)
  end

  describe 'POST /puzzle_invites' do
    it 'creates a puzzle_invite notification' do
      expect {
        post puzzle_invites_path,
             params: { solution_id: solution.id, invitee_id: friend.id },
             headers: { 'Accept' => 'application/json' }
      }.to change(Notification, :count).by(1)

      notification = Notification.last
      expect(notification.user).to eq friend
      expect(notification.notification_type).to eq 'puzzle_invite'
      expect(notification.notifiable).to eq solution
    end

    it 'returns 404 for non-team solution' do
      solo = create(:solution, crossword: crossword, user: user, team: false)
      post puzzle_invites_path,
           params: { solution_id: solo.id, invitee_id: friend.id },
           headers: { 'Accept' => 'application/json' }
      expect(response).to have_http_status(:not_found)
    end

    it 'returns 422 if invitee is not a friend' do
      stranger = create(:user)
      post puzzle_invites_path,
           params: { solution_id: solution.id, invitee_id: stranger.id },
           headers: { 'Accept' => 'application/json' }
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it 'returns 404 for nonexistent solution' do
      post puzzle_invites_path,
           params: { solution_id: 99999, invitee_id: friend.id },
           headers: { 'Accept' => 'application/json' }
      expect(response).to have_http_status(:not_found)
    end
  end
end
```

---

## Critical Implementation Notes for Builder

### Column type matching
`notifications.user_id` and `notifications.actor_id` must be `t.integer` — `users.id` is `integer` (not `bigint`). Using `t.references` creates `bigint` FKs → type mismatch.

### FriendRequest has no `id` column
- Schema: `create_table "friend_requests", id: false`
- All lookups by `(sender_id, recipient_id)` composite
- Cannot use polymorphic `notifiable` — friend notifications have `notifiable: nil`
- No `dependent: :destroy` on User `has_many :friend_requests`

### ActionCable connection allows nil `current_user`
`ApplicationCable::Connection#find_verified_user` returns nil for anonymous. `NotificationsChannel` must check and `reject` if nil.

### Sprockets asset pipeline
New JS in `app/assets/javascripts/` auto-linked by `manifest.js` (`link_tree ../javascripts .js`). No manifest changes needed. New SCSS partials need `@import` in the main stylesheet.

### Stimulus controller pattern
`class extends Stimulus.Controller`, `.targets = [...]`, `window.StimulusApp.register('name', Class)`. NOT ES module syntax.

### Test patterns
- Request specs: `log_in_as(user)` with `:with_test_password` trait
- Always stub `ActionCable.server.broadcast`
- Use `expect()` only — no `should` syntax
- Stub `ApplicationController.render` with `.and_call_original` when testing notification creation in request specs (service needs to render partial)

### Deployment order
1. Phase 1: `rails db:migrate` + deploy → bell icon, empty inbox, ActionCable connects
2. Phase 2: deploy → friend buttons functional on profiles
3. Phase 3: deploy → comments generate notifications
4. Phase 4: deploy → team page friend picker

Run `bundle exec rspec` after each phase.

### Icon verification
Builder should verify `bell.svg` exists in `app/assets/images/icons/`. If not, either add it from Lucide set or keep `mail` icon. Also verify `clock.svg`, `user-plus.svg`, `check-check.svg` exist for the notification UI.

---

## Files Summary

### New files (20)
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
| `app/assets/stylesheets/_notifications.scss` | 1 |
| `spec/factories/notification_factory.rb` | 1 |
| `spec/models/notification_spec.rb` | 1 |
| `spec/services/notification_service_spec.rb` | 1 |
| `spec/requests/notifications_spec.rb` | 1 |
| `app/controllers/friend_requests_controller.rb` | 2 |
| `app/views/friend_requests/create.turbo_stream.erb` | 2 |
| `app/views/friend_requests/accept.turbo_stream.erb` | 2 |
| `spec/requests/friend_requests_spec.rb` | 2 |
| `app/controllers/puzzle_invites_controller.rb` | 4 |
| `app/assets/javascripts/controllers/invite_controller.js` | 4 |
| `spec/requests/puzzle_invites_spec.rb` | 4 |

### Modified files (9)
| File | Phase | Change |
|------|-------|--------|
| `app/models/user.rb` | 1 | `has_many :notifications`, friend request associations |
| `app/controllers/application_controller.rb` | 1 | `load_unread_notification_count` before_action |
| `app/views/layouts/application.html.haml` | 1 | Conditional ActionCable JS for logged-in users |
| `app/views/layouts/partials/_nav.html.haml` | 1 | Badge count, link to `/notifications`, bell icon |
| `app/assets/stylesheets/_nav.scss` | 1 | `.xw-badge` styles |
| `config/routes.rb` | 1,2,4 | Notification, friend_request, puzzle_invite, API friends routes |
| `app/views/users/partials/_user.html.haml` | 2 | Functional friend request buttons |
| `app/controllers/comments_controller.rb` | 3 | NotificationService calls in add_comment + reply |
| `app/views/crosswords/partials/_team.html.haml` | 4 | Invite friend section |

### Deleted files (2)
| File | Phase | Reason |
|------|-------|--------|
| `app/assets/javascripts/cable.js` | 1 | Dead code — `App.cable` unused |
| `app/assets/javascripts/channels/chatrooms.js` | 1 | Dead code — empty manifest |
