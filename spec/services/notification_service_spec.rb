RSpec.describe NotificationService do
  let_it_be(:user) { create(:user) }
  let_it_be(:actor) { create(:user) }

  before do
    # Stub ActionCable broadcasts to avoid needing a real connection
    allow(ActionCable.server).to receive(:broadcast)
    # Stub ApplicationController.render to avoid needing view context
    allow(ApplicationController).to receive(:render).and_return('<div>notification</div>')
  end

  describe '.notify' do
    it 'creates a notification with correct attributes' do
      notification = NotificationService.notify(
        user: user, actor: actor, type: 'friend_request'
      )

      expect(notification).to be_a(Notification)
      expect(notification).to be_persisted
      expect(notification.user).to eq(user)
      expect(notification.actor).to eq(actor)
      expect(notification.notification_type).to eq('friend_request')
    end

    it 'creates a notification with notifiable and metadata' do
      comment = create(:comment)
      metadata = { crossword_id: 1, crossword_title: 'Test Puzzle' }

      notification = NotificationService.notify(
        user: user, actor: actor, type: 'comment_on_puzzle',
        notifiable: comment, metadata: metadata
      )

      expect(notification.notifiable).to eq(comment)
      expect(notification.metadata).to eq('crossword_id' => 1, 'crossword_title' => 'Test Puzzle')
    end

    it 'returns nil for self-notification' do
      result = NotificationService.notify(
        user: user, actor: user, type: 'friend_request'
      )

      expect(result).to be_nil
      expect(Notification.count).to eq(0)
    end

    it 'returns nil on duplicate (dedup index)' do
      NotificationService.notify(user: user, actor: actor, type: 'friend_request')

      duplicate = NotificationService.notify(user: user, actor: actor, type: 'friend_request')
      expect(duplicate).to be_nil
      expect(Notification.count).to eq(1)
    end

    it 'broadcasts to ActionCable after creation' do
      expect(ActionCable.server).to receive(:broadcast).with(
        "notifications_#{user.id}",
        hash_including(event: 'new_notification', html: anything, unread_count: anything)
      )

      NotificationService.notify(user: user, actor: actor, type: 'friend_request')
    end

    it 'handles nil notifiable (friend_request type)' do
      notification = NotificationService.notify(
        user: user, actor: actor, type: 'friend_request', notifiable: nil
      )

      expect(notification).to be_persisted
      expect(notification.notifiable).to be_nil
    end

    it 'does not raise when broadcast fails' do
      allow(ActionCable.server).to receive(:broadcast).and_raise(StandardError, 'Redis down')

      expect {
        NotificationService.notify(user: user, actor: actor, type: 'friend_request')
      }.not_to raise_error

      expect(Notification.count).to eq(1)
    end
  end
end
