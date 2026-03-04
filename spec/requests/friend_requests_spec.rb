RSpec.describe 'FriendRequests', type: :request do
  let_it_be(:user) { create(:user, :with_test_password) }
  let_it_be(:other_user) { create(:user) }

  before do
    # Stub ActionCable broadcasts
    allow(ActionCable.server).to receive(:broadcast)
    allow(ApplicationController).to receive(:render).and_call_original
  end

  describe 'POST /friend_requests' do
    it 'redirects anonymous users' do
      post '/friend_requests', params: { recipient_id: other_user.id }
      expect(response).to redirect_to(account_required_path(redirect: '/friend_requests'))
    end

    it 'creates a friend request and sends notification' do
      log_in_as(user)
      expect {
        post '/friend_requests', params: { recipient_id: other_user.id }
      }.to change(FriendRequest, :count).by(1)
        .and change(Notification, :count).by(1)
    end

    it 'returns 404 for nonexistent recipient' do
      log_in_as(user)
      post '/friend_requests', params: { recipient_id: 999999 }
      expect(response).to have_http_status(:not_found)
    end

    it 'returns 422 for self-request' do
      log_in_as(user)
      post '/friend_requests', params: { recipient_id: user.id }
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it 'returns 422 if already friends' do
      log_in_as(user)
      Friendship.create!(user_id: user.id, friend_id: other_user.id)
      post '/friend_requests', params: { recipient_id: other_user.id }
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it 'returns 422 for duplicate request' do
      log_in_as(user)
      FriendRequest.create!(sender: user, recipient: other_user)
      post '/friend_requests', params: { recipient_id: other_user.id }
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it 'returns 422 when reverse request exists' do
      log_in_as(user)
      FriendRequest.create!(sender: other_user, recipient: user)
      post '/friend_requests', params: { recipient_id: other_user.id }
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe 'POST /friend_requests/accept' do
    it 'creates friendship, destroys request, sends notification, marks notification read' do
      log_in_as(user)
      FriendRequest.create!(sender: other_user, recipient: user)
      create(:notification, user: user, actor: other_user, notification_type: 'friend_request')

      post '/friend_requests/accept', params: { sender_id: other_user.id }

      expect(Friendship.where(user_id: other_user.id, friend_id: user.id)).to exist
      expect(FriendRequest.where(sender_id: other_user.id, recipient_id: user.id)).not_to exist
      expect(Notification.where(user_id: user.id, actor_id: other_user.id,
                                notification_type: 'friend_request').first.read_at).not_to be_nil
    end

    it 'returns 404 for nonexistent request' do
      log_in_as(user)
      post '/friend_requests/accept', params: { sender_id: 999999 }
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'DELETE /friend_requests/reject' do
    it 'destroys request and marks notification read' do
      log_in_as(user)
      FriendRequest.create!(sender: other_user, recipient: user)
      create(:notification, user: user, actor: other_user, notification_type: 'friend_request')

      delete '/friend_requests/reject', params: { sender_id: other_user.id }

      expect(FriendRequest.where(sender_id: other_user.id, recipient_id: user.id)).not_to exist
      expect(Notification.where(user_id: user.id, actor_id: other_user.id,
                                notification_type: 'friend_request').first.read_at).not_to be_nil
      expect(response).to redirect_to(notifications_path)
    end
  end
end
