class FriendRequest < ApplicationRecord
  belongs_to :sender, class_name: 'User'
  belongs_to :recipient, class_name: 'User'

  validates :sender_id, uniqueness: { scope: :recipient_id }
  validate :cannot_send_to_self

  private

  def cannot_send_to_self
    errors.add(:recipient_id, "can't send a friend request to yourself") if sender_id == recipient_id
  end
end
