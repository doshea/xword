# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  first_name             :string(18)
#  last_name              :string(24)
#  username               :string(16)       not null
#  email                  :string(254)      not null
#  image                  :text
#  location               :string(255)
#  is_admin               :boolean          default(FALSE)
#  password_digest        :string(255)
#  auth_token             :string(255)
#  created_at             :datetime
#  updated_at             :datetime
#  password_reset_token   :string(255)
#  password_reset_sent_at :datetime
#  verified               :boolean          default(FALSE)
#  verification_token     :string
#

describe User do
  context 'setup' do
    it { should have_secure_password }
  end
  context 'validations' do
    let!(:user) { create(:user)}
    it {should validate_uniqueness_of(:email)}
    it {should validate_uniqueness_of(:username)}
    it {should validate_presence_of(:email)}
    it {should validate_presence_of(:username)}

    context 'with valid attributes' do
      subject { user }
      it {should be_an_instance_of User}
      it {should be_valid}
      it {should allow_value(subject.first_name).for(:first_name)}
      it {should allow_value(subject.last_name).for(:last_name)}
      it {should allow_value(subject.email).for(:email)}
      it {should allow_value(subject.username).for(:username)}
      it {should allow_value(subject.password).for(:password)}
      it {should allow_value(subject.password_confirmation).for(:password_confirmation)}
      it {should allow_value(subject.location).for(:location)}
    end
    context 'with invalid nil attributes' do
      it {should_not allow_value(nil).for(:email)}
      it {should_not allow_value(nil).for(:username)}
      it {should_not allow_value(nil).for(:password)}
    end
    context 'with invalid (too short) attributes' do
      it {should_not allow_value(build(:user, :short_first_name).first_name).for(:first_name)}
      it {should_not allow_value(build(:user, :short_last_name).last_name).for(:last_name)}
      it {should_not allow_value(build(:user, :short_email).email).for(:email)}
      it {should_not allow_value(build(:user, :short_username).username).for(:username)}
      it {should_not allow_value(build(:user, :short_password).password).for(:password)}
    end
    context 'with invalid (too long) attributes' do
      it {should_not allow_value(build(:user, :long_first_name).first_name).for(:first_name)}
      it {should_not allow_value(build(:user, :long_last_name).last_name).for(:last_name)}
      it {should_not allow_value(build(:user, :long_email).email).for(:email)}
      it {should_not allow_value(build(:user, :long_username).username).for(:username)}
      it {should_not allow_value(build(:user, :long_password).password).for(:password)}
    end
  end
  context 'associations' do
    it { should have_many :crosswords }
    it { should have_many :comments }
    it { should have_many :solutions }
    it { should have_many :clues }
    it { should have_many :favorite_puzzles }
    it { should have_many(:favorites).through(:favorite_puzzles).source(:crossword) }
    it { should have_many(:solution_partnerings).dependent(:destroy) }
    it { should have_many(:team_solutions).through(:solution_partnerings).source(:solution) }
  end

  describe '#rotate_auth_token!' do
    let(:user) { create(:user) }

    it 'changes the auth_token' do
      old_token = user.auth_token
      user.rotate_auth_token!
      expect(user.auth_token).not_to eq old_token
    end

    it 'persists the new token to the database' do
      user.rotate_auth_token!
      expect(user.reload.auth_token).to eq user.auth_token
    end
  end

  describe '#friends' do
    let(:user)     { create(:user) }
    let(:friend_a) { create(:user) }
    let(:friend_b) { create(:user) }
    let(:stranger) { create(:user) }

    before do
      Friendship.create!(user_id: user.id, friend_id: friend_a.id)
      Friendship.create!(user_id: friend_b.id, friend_id: user.id)
    end

    it 'returns friends from both sides of the friendship' do
      expect(user.friends).to contain_exactly(friend_a, friend_b)
    end

    it 'does not include non-friends' do
      expect(user.friends).not_to include(stranger)
    end

    it 'returns an ActiveRecord::Relation' do
      expect(user.friends).to be_a(ActiveRecord::Relation)
    end
  end

  describe '#deleted?' do
    let(:user) { create(:user) }

    it 'returns false when deleted_at is nil' do
      expect(user.deleted?).to be false
    end

    it 'returns true when deleted_at is set' do
      user.update_columns(deleted_at: Time.current)
      expect(user.deleted?).to be true
    end
  end

  describe '#display_name' do
    let(:user) { create(:user, first_name: 'Jane', last_name: 'Doe') }

    it 'returns "[Deleted Account]" when user is deleted' do
      user.update_columns(deleted_at: Time.current)
      expect(user.display_name).to eq('[Deleted Account]')
    end

    it 'returns full name when not deleted' do
      expect(user.display_name).to eq('Jane Doe')
    end
  end

  describe '#notification_muted?' do
    let(:user) { create(:user) }

    it 'returns false when preferences are empty (all enabled by default)' do
      expect(user.notification_muted?('friend_request')).to be false
    end

    it 'returns true when a type is explicitly set to false' do
      user.update!(notification_preferences: { 'friend_request' => false })
      expect(user.notification_muted?('friend_request')).to be true
    end

    it 'returns false for types not in the preferences hash' do
      user.update!(notification_preferences: { 'friend_request' => false })
      expect(user.notification_muted?('comment_reply')).to be false
    end

    it 'returns false when a type is explicitly set to true' do
      user.update!(notification_preferences: { 'friend_request' => true })
      expect(user.notification_muted?('friend_request')).to be false
    end
  end

  describe '#notification_preferences=' do
    let(:user) { create(:user) }

    it 'coerces form string "0" to false' do
      user.notification_preferences = { 'friend_request' => '0' }
      expect(user.notification_preferences['friend_request']).to be false
    end

    it 'coerces form string "1" to true' do
      user.notification_preferences = { 'friend_request' => '1' }
      expect(user.notification_preferences['friend_request']).to be true
    end

    it 'ignores keys not in NOTIFICATION_TYPES' do
      user.notification_preferences = { 'bogus_type' => '1', 'friend_request' => '0' }
      expect(user.notification_preferences).to eq({ 'friend_request' => false })
    end
  end

  describe '#anonymize!' do
    let(:user) { create(:user, first_name: 'Jane', last_name: 'Doe', location: 'NYC') }
    let(:friend) { create(:user) }
    let(:crossword) { create(:crossword, user: user) }

    before do
      Friendship.create!(user_id: user.id, friend_id: friend.id)
      user.anonymize!
      user.reload
    end

    it 'strips PII' do
      expect(user.first_name).to be_nil
      expect(user.last_name).to be_nil
      expect(user.location).to be_nil
      expect(user.password_digest).to be_nil
      expect(user.auth_token).to be_nil
    end

    it 'sets anonymized email and username' do
      expect(user.email).to eq("deleted_#{user.id}@deleted.invalid")
      expect(user.username).to eq("deleted_#{user.id}")
    end

    it 'sets deleted_at' do
      expect(user.deleted_at).to be_present
    end

    it 'removes friendships' do
      expect(Friendship.where(user_id: user.id).or(Friendship.where(friend_id: user.id)).count).to eq(0)
    end

    it 'preserves crosswords (nullifies user_id via dependent: :nullify only on destroy)' do
      # anonymize! does NOT call destroy, so crosswords keep their user_id
      expect(crossword.reload.user_id).to eq(user.id)
    end

    it 'returns "[Deleted Account]" for display_name' do
      expect(user.display_name).to eq('[Deleted Account]')
    end
  end
end
