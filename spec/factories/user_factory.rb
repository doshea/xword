# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  first_name             :string(255)
#  last_name              :string(255)
#  username               :string(255)      not null
#  email                  :string(255)      not null
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

require 'spec_methods'

FactoryGirl.define do

  factory :min_user, class: User do
    email Faker::Internet.email
    username 'min_user'
    password 'abcde'
    password_confirmation { "#{password}" }
  end
  factory :user, class: User do
    first_name Faker::Name.first_name
    last_name Faker::Name.last_name
    username Faker::Internet.user_name
    email Faker::Internet.email
    password Faker::Lorem.characters(5)
    password_confirmation { "#{password}" }
    location 'Bobville'
  end
  factory :admin, class: User do
    first_name 'Ed'
    last_name 'Ministrator'
    username 'admin'
    is_admin true
    password 'abcde'
    password_confirmation { "#{password}" }
  end
  factory :invalid_user_nil, class: User do
    email nil
    username nil
    password nil
    password_confirmation nil

  end
  factory :invalid_user_min, class: User do
    first_name Faker::Lorem.characters(1)
    last_name Faker::Lorem.characters(1)
    email Faker::Lorem.characters(4)
    username Faker::Lorem.characters(3)
    password Faker::Lorem.characters(4)
    password_confirmation Faker::Lorem.characters(4)

  end
  factory :invalid_user_max, class: User do
    first_name Faker::Lorem.characters(19)
    last_name Faker::Lorem.characters(25)
    email Faker::Lorem.characters(41)
    username Faker::Lorem.characters(21)
    password Faker::Lorem.characters(17)
    password_confirmation Faker::Lorem.characters(17)
  end

end
