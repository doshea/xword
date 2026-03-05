class Friendship < ApplicationRecord
  belongs_to :friend_one, class_name: 'User', foreign_key: :user_id, inverse_of: :friendship_twos
  belongs_to :friend_two, class_name: 'User', foreign_key: :friend_id, inverse_of: :friendship_ones

  validates :user_id, uniqueness: { scope: :friend_id }
  validate :cannot_befriend_self

  private

  def cannot_befriend_self
    errors.add(:friend_id, "can't be the same as user") if user_id == friend_id
  end
end
