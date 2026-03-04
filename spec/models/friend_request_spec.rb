describe FriendRequest do
  let(:user_a) { create(:user) }
  let(:user_b) { create(:user) }

  context 'associations' do
    it { should belong_to(:sender).class_name('User') }
    it { should belong_to(:recipient).class_name('User') }
  end

  context 'validations' do
    it 'requires sender and recipient' do
      fr = FriendRequest.new
      expect(fr).not_to be_valid
      expect(fr.errors[:sender]).to be_present
      expect(fr.errors[:recipient]).to be_present
    end

    it 'rejects duplicate requests' do
      FriendRequest.create!(sender: user_a, recipient: user_b)
      duplicate = FriendRequest.new(sender: user_a, recipient: user_b)
      expect(duplicate).not_to be_valid
    end

    it 'prevents sending a request to yourself' do
      fr = FriendRequest.new(sender: user_a, recipient: user_a)
      expect(fr).not_to be_valid
      expect(fr.errors[:recipient_id]).to include("can't send a friend request to yourself")
    end
  end
end
