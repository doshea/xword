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