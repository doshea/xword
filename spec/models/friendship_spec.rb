describe Friendship do
  context 'associations' do
    it { should belong_to(:friend_one).class_name('User').with_foreign_key(:user_id) }
    it { should belong_to(:friend_two).class_name('User').with_foreign_key(:friend_id) }
  end

  context 'validations' do
    let(:user_a) { create(:user) }
    let(:user_b) { create(:user) }
    let!(:friendship) { Friendship.create!(user_id: user_a.id, friend_id: user_b.id) }

    it 'rejects duplicate friendships' do
      duplicate = Friendship.new(user_id: user_a.id, friend_id: user_b.id)
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:user_id]).to be_present
    end

    it 'allows the reverse direction' do
      reverse = Friendship.new(user_id: user_b.id, friend_id: user_a.id)
      expect(reverse).to be_valid
    end
  end
end
