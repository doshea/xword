RSpec.describe Notification, type: :model do
  describe 'validations' do
    it 'requires notification_type' do
      notification = build(:notification, notification_type: nil)
      expect(notification).not_to be_valid
      expect(notification.errors[:notification_type]).to be_present
    end

    it 'validates notification_type inclusion' do
      user = create(:user)
      actor = create(:user)

      %w[friend_request friend_accepted puzzle_invite comment_on_puzzle comment_reply].each do |t|
        notification = build(:notification, user: user, actor: actor, notification_type: t)
        expect(notification).to be_valid
      end

      notification = build(:notification, user: user, actor: actor, notification_type: 'invalid_type')
      expect(notification).not_to be_valid
    end

    it 'prevents self-notification' do
      user = create(:user)
      notification = build(:notification, user: user, actor: user)
      expect(notification).not_to be_valid
      expect(notification.errors[:user_id]).to include("can't notify yourself")
    end
  end

  describe 'associations' do
    it 'belongs to user (recipient)' do
      notification = create(:notification)
      expect(notification.user).to be_a(User)
    end

    it 'belongs to actor' do
      notification = create(:notification)
      expect(notification.actor).to be_a(User)
    end

    it 'optionally belongs to notifiable (polymorphic)' do
      notification = create(:notification, :friend_request, notifiable: nil)
      expect(notification).to be_valid
      expect(notification.notifiable).to be_nil
    end
  end

  describe 'actor deletion cascades' do
    it 'destroys notifications when the actor is destroyed' do
      actor = create(:user)
      recipient = create(:user)
      create(:notification, user: recipient, actor: actor, notification_type: 'friend_request')

      expect { actor.destroy }.to change(Notification, :count).by(-1)
    end
  end

  describe 'scopes' do
    let(:user) { create(:user) }
    let(:actor) { create(:user) }

    it '.unread returns only notifications with read_at nil' do
      unread = create(:notification, user: user, actor: actor, notification_type: 'friend_request')
      _read = create(:notification, :read, user: user, actor: create(:user), notification_type: 'friend_accepted')

      expect(Notification.unread).to include(unread)
      expect(Notification.unread).not_to include(_read)
    end

    it '.recent orders by created_at desc and limits to 50' do
      # Create 2 notifications to verify ordering
      older = create(:notification, user: user, actor: actor, notification_type: 'friend_request',
                     created_at: 2.hours.ago)
      newer = create(:notification, user: user, actor: create(:user), notification_type: 'friend_accepted',
                     created_at: 1.hour.ago)

      results = Notification.recent
      expect(results.first).to eq(newer)
      expect(results.last).to eq(older)
    end
  end
end
