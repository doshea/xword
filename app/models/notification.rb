class Notification < ApplicationRecord
  belongs_to :user, inverse_of: :notifications    # recipient
  belongs_to :actor, class_name: 'User'           # who triggered it
  belongs_to :notifiable, polymorphic: true, optional: true

  validates :notification_type, presence: true
  validates :notification_type, inclusion: {
    in: %w[friend_request friend_accepted puzzle_invite comment_on_puzzle comment_reply]
  }
  validate :cannot_notify_self

  scope :unread, -> { where(read_at: nil) }
  scope :recent, -> { order(created_at: :desc).limit(50) }

  private

  def cannot_notify_self
    errors.add(:user_id, "can't notify yourself") if user_id == actor_id
  end
end
