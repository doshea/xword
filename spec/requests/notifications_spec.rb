RSpec.describe 'Notifications', type: :request do
  let_it_be(:user) { create(:user, :with_test_password) }
  let_it_be(:actor) { create(:user) }

  describe 'GET /notifications' do
    it 'redirects anonymous users to account_required' do
      get '/notifications'
      expect(response).to redirect_to(account_required_path(redirect: '/notifications'))
    end

    it 'shows notifications for logged-in user' do
      log_in_as(user)
      create(:notification, user: user, actor: actor, notification_type: 'friend_request')

      get '/notifications'
      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Notifications')
    end

    it 'does not show other users\' notifications' do
      log_in_as(user)
      other_user = create(:user)
      create(:notification, user: other_user, actor: actor, notification_type: 'friend_request')

      get '/notifications'
      expect(response).to have_http_status(:ok)
      expect(response.body).to include('No notifications yet.')
    end
  end

  describe 'PATCH /notifications/:id/mark_read' do
    it 'sets read_at on the notification' do
      log_in_as(user)
      notification = create(:notification, user: user, actor: actor, notification_type: 'friend_request')

      patch mark_read_notification_path(notification)
      expect(notification.reload.read_at).not_to be_nil
    end

    it 'returns 404 for notifications belonging to other users' do
      log_in_as(user)
      other_user = create(:user)
      notification = create(:notification, user: other_user, actor: actor, notification_type: 'friend_request')

      patch mark_read_notification_path(notification)
      expect(response).to have_http_status(:not_found)
    end

    it 'redirects anonymous users' do
      notification = create(:notification, user: user, actor: actor, notification_type: 'friend_request')
      patch mark_read_notification_path(notification)
      expect(response).to redirect_to(account_required_path(redirect: mark_read_notification_path(notification)))
    end
  end

  describe 'PATCH /notifications/mark_all_read' do
    it 'marks all unread notifications as read' do
      log_in_as(user)
      n1 = create(:notification, user: user, actor: actor, notification_type: 'friend_request')
      n2 = create(:notification, user: user, actor: create(:user), notification_type: 'friend_accepted')

      patch mark_all_read_notifications_path
      expect(n1.reload.read_at).not_to be_nil
      expect(n2.reload.read_at).not_to be_nil
    end

    it 'does not affect already-read notifications' do
      log_in_as(user)
      read_notification = create(:notification, :read, user: user, actor: actor,
                                  notification_type: 'friend_request')
      original_read_at = read_notification.read_at

      patch mark_all_read_notifications_path
      expect(read_notification.reload.read_at).to be_within(1.second).of(original_read_at)
    end

    it 'returns no_content for JSON requests' do
      log_in_as(user)
      create(:notification, user: user, actor: actor, notification_type: 'friend_request')

      patch mark_all_read_notifications_path,
            headers: { 'Accept' => 'application/json' }
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'PATCH /notifications/:id/mark_read (JSON)' do
    it 'returns no_content for JSON requests' do
      log_in_as(user)
      notification = create(:notification, user: user, actor: actor,
                            notification_type: 'friend_request')

      patch mark_read_notification_path(notification),
            headers: { 'Accept' => 'application/json' }
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'GET /notifications/dropdown' do
    context 'when logged in' do
      before { log_in_as(user) }

      it 'returns HTML with dropdown list container' do
        get dropdown_notifications_path, headers: { 'Accept' => 'text/html' }
        expect(response).to have_http_status(:ok)
        expect(response.body).to include('dropdown-notifications-list')
      end

      it 'includes existing notifications' do
        create(:notification, user: user, actor: actor, notification_type: 'friend_request')
        get dropdown_notifications_path, headers: { 'Accept' => 'text/html' }
        expect(response.body).to include(actor.display_name)
      end

      it 'includes "See all" link' do
        get dropdown_notifications_path, headers: { 'Accept' => 'text/html' }
        expect(response.body).to include('See all notifications')
      end

      it 'shows empty state when no notifications' do
        get dropdown_notifications_path, headers: { 'Accept' => 'text/html' }
        expect(response.body).to include('No notifications yet')
      end
    end

    context 'when not logged in' do
      it 'redirects to account_required' do
        get dropdown_notifications_path
        expect(response).to redirect_to(account_required_path(redirect: dropdown_notifications_path))
      end
    end
  end
end
