class Friendship < ApplicationRecord
  belongs_to :friend_one, class_name: 'User', foreign_key: :user_id, inverse_of: :friendship_twos, optional: true
  belongs_to :friend_two, class_name: 'User', foreign_key: :friend_id, inverse_of: :friendship_ones, optional: true
end