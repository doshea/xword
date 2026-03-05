# Handles friend request acceptance: creates Friendship, deletes FriendRequest,
# notifies the original sender, and marks the request notification as read.
class FriendshipService
  # Accept a friend request. Returns the new Friendship.
  # Raises ActiveRecord::RecordNotFound if the request doesn't exist.
  def self.accept(sender:, recipient:)
    freq = FriendRequest.find_by!(sender_id: sender.id, recipient_id: recipient.id)

    friendship = nil
    ActiveRecord::Base.transaction do
      friendship = Friendship.create!(user_id: sender.id, friend_id: recipient.id)
      # FriendRequest has id: false — destroy! would fail. Use delete_all.
      FriendRequest.where(sender_id: sender.id, recipient_id: recipient.id).delete_all
    end

    NotificationService.notify(
      user: sender, actor: recipient,
      type: 'friend_accepted'
    )

    mark_request_notification_read(user: recipient, actor: sender)

    friendship
  end

  # Reject (or cancel) a friend request. Deletes the request and marks notification as read.
  def self.reject(sender:, recipient:)
    FriendRequest.where(sender_id: sender.id, recipient_id: recipient.id).delete_all

    mark_request_notification_read(user: recipient, actor: sender)
  end

  def self.mark_request_notification_read(user:, actor:)
    Notification.where(user_id: user.id, actor_id: actor.id,
                       notification_type: 'friend_request')
                .unread.update_all(read_at: Time.current)
  end
  private_class_method :mark_request_notification_read
end
