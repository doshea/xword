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
#  is_admin               :boolean          default("false")
#  password_digest        :string(255)
#  auth_token             :string(255)
#  created_at             :datetime
#  updated_at             :datetime
#  password_reset_token   :string(255)
#  password_reset_sent_at :datetime
#  verified               :boolean          default("false")
#  verification_token     :string
#

FactoryGirl.define do

  #TODO DRY up these factories with inheritance: https://github.com/thoughtbot/factory_girl/blob/master/GETTING_STARTED.md#inheritance
  factory :user do
    username {Faker::Lorem.characters((User::MIN_USERNAME_LENGTH..User::MAX_USERNAME_LENGTH).to_a.sample)}
    email {Faker::Internet.email}
    password {Faker::Lorem.characters((User::MIN_PASSWORD_LENGTH..User::MAX_PASSWORD_LENGTH).to_a.sample)}
    password_confirmation { "#{password}" }

    factory :full_user do
      first_name {Faker::Name.first_name}
      last_name {Faker::Name.last_name}
      location {"#{Faker::Address.street_address}, #{Faker::Address.city}, #{Faker::Address.state_abbr}"}
    end

    factory :admin do
      is_admin true
    end

    ### INVALID ###

    # Short_attributes
    trait :short_first_name do
      first_name Faker::Lorem.characters(User::MIN_NAME_LENGTH - 1)
    end
    trait :short_last_name do
      last_name Faker::Lorem.characters(User::MIN_NAME_LENGTH - 1)
    end
    trait :short_email do
      email Faker::Lorem.characters(User::MIN_EMAIL_LENGTH - 1)
    end
    trait :short_username do
      username Faker::Lorem.characters(User::MIN_USERNAME_LENGTH - 1)
    end
    trait :short_password do
      password Faker::Lorem.characters(User::MIN_PASSWORD_LENGTH - 1)
    end

    # Long attributes
    trait :long_first_name do
      first_name Faker::Lorem.characters(User::MAX_FIRST_NAME_LENGTH + 1)
    end
    trait :long_last_name do
      last_name Faker::Lorem.characters(User::MAX_LAST_NAME_LENGTH + 1)
    end
    trait :long_email do
      email Faker::Lorem.characters(User::MAX_EMAIL_LENGTH + 1)
    end
    trait :long_username do
      username Faker::Lorem.characters(User::MAX_USERNAME_LENGTH + 1)
    end
    trait :long_password do
      password Faker::Lorem.characters(User::MAX_PASSWORD_LENGTH + 1)
    end


  end

end
