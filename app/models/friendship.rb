class Friendship < ActiveRecord::Base
  belongs_to :friend_one, class_name: 'User', foreign_key: :user_id
  belongs_to :friend_two, class_name: 'User', foreign_key: :friend_id
end