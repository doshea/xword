# == Schema Information
#
# Table name: users
#
#  id              :integer          not null, primary key
#  first_name      :string(255)
#  last_name       :string(255)
#  username        :string(255)      not null
#  email           :string(255)      not null
#  is_admin        :boolean          default(FALSE)
#  password_digest :string(255)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  image           :text
#  location        :string(255)
#  auth_token      :string(255)
#

require 'spec_helper'

describe User do
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
    end
    context 'with invalid nil attributes' do
      let(:invalid_user) { build :invalid_user_nil}
      it {should_not allow_value(invalid_user.email).for(:email)}
      it {should_not allow_value(invalid_user.username).for(:username)}
      it {should_not allow_value(invalid_user.password).for(:password)}
    end
    context 'with invalid sub-minimal attributes' do
      let(:invalid_user) { build :invalid_user_min}
      it {should_not allow_value(invalid_user.first_name).for(:first_name)}
      it {should_not allow_value(invalid_user.last_name).for(:last_name)}
      it {should_not allow_value(invalid_user.email).for(:email)}
      it {should_not allow_value(invalid_user.username).for(:username)}
      it {should_not allow_value(invalid_user.password).for(:password)}
    end
    context 'with invalid super-maximal attributes' do
      let(:invalid_user) { build :invalid_user_max}
      it {should_not allow_value(invalid_user.first_name).for(:first_name)}
      it {should_not allow_value(invalid_user.last_name).for(:last_name)}
      it {should_not allow_value(invalid_user.email).for(:email)}
      it {should_not allow_value(invalid_user.username).for(:username)}
      it {should_not allow_value(invalid_user.password).for(:password)}
    end
  end
  context 'associations' do
    it {should have_many :crosswords}
    it {should have_many :comments}
    it {should have_many :clues}
  end
  describe 'instance methods' do

  end
  describe 'class methods' do

  end
end
