RSpec.describe FriendshipService do
  let(:sender) { create(:user) }
  let(:recipient) { create(:user) }

  describe '.accept' do
    before do
      FriendRequest.create!(sender: sender, recipient: recipient)
    end

    it 'creates a Friendship between sender and recipient' do
      expect { FriendshipService.accept(sender: sender, recipient: recipient) }
        .to change(Friendship, :count).by(1)
    end

    it 'deletes the FriendRequest' do
      expect { FriendshipService.accept(sender: sender, recipient: recipient) }
        .to change(FriendRequest, :count).by(-1)
    end

    it 'returns the new Friendship' do
      result = FriendshipService.accept(sender: sender, recipient: recipient)
      expect(result).to be_a(Friendship)
      expect(result.user_id).to eq(sender.id)
      expect(result.friend_id).to eq(recipient.id)
    end

    it 'raises RecordNotFound when no request exists' do
      FriendRequest.where(sender_id: sender.id, recipient_id: recipient.id).delete_all
      expect { FriendshipService.accept(sender: sender, recipient: recipient) }
        .to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'marks the friend_request notification as read' do
      notification = create(:notification, user: recipient, actor: sender,
                            notification_type: 'friend_request')
      FriendshipService.accept(sender: sender, recipient: recipient)
      expect(notification.reload.read_at).to be_present
    end
  end

  describe '.reject' do
    before do
      FriendRequest.create!(sender: sender, recipient: recipient)
    end

    it 'deletes the FriendRequest' do
      expect { FriendshipService.reject(sender: sender, recipient: recipient) }
        .to change(FriendRequest, :count).by(-1)
    end

    it 'does not create a Friendship' do
      expect { FriendshipService.reject(sender: sender, recipient: recipient) }
        .not_to change(Friendship, :count)
    end

    it 'marks the friend_request notification as read' do
      notification = create(:notification, user: recipient, actor: sender,
                            notification_type: 'friend_request')
      FriendshipService.reject(sender: sender, recipient: recipient)
      expect(notification.reload.read_at).to be_present
    end
  end
end
