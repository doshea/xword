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

FactoryGirl.define do

  factory :min_user, class: User do
    email 'min_user@gmail.com'
    username 'min_user'
    password 'abcde'
    password_confirmation 'abcde'
  end
  factory :user, class: User do
    first_name 'bob'
    last_name 'bobson'
    username 'bobbb'
    email 'bob@gmail.com'
    password 'abcde'
    password_confirmation 'abcde'
    location 'Bobville'
  end
  factory :admin, class: User do
    first_name 'Ed'
    last_name 'Ministrator'
    username 'admin'
    is_admin true
    password 'abcde'
    password_confirmation 'abcde'
  end

end
