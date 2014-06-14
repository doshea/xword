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
    it { should have_many(:team_solutions).through(:solution_partnerings).source(:user) }
  end
  describe 'instance methods' do

  end
  describe 'class methods' do

  end
end
