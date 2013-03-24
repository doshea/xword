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
#

require 'spec_helper'

describe User do
  describe '.new' do
    it 'creates an instance of User' do
      user = User.new
      expect(user).to be_an_instance_of(User)
    end
    it 'has first_name, last_name, username, email and password' do
      user = User.new(:first_name => 'bob', :last_name => 'bobson', :email => 'bob@gmail.com', :username => 'bobbb', :password => 'abc', :password_confirmation => 'abc')
      expect(user.first_name).to eq 'bob'
      expect(user.last_name).to eq 'bobson'
      expect(user.email).to eq 'bob@gmail.com'
      expect(user.username).to eq 'bobbb'
      expect(user.password).to eq 'abc'
      expect(user.password_confirmation).to eq 'abc'
    end
  end

end
