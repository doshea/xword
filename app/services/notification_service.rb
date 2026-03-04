class NotificationService
  # Single entry point for creating notifications.
  # Returns nil if self-notification (user == actor).
  # Rescues RecordNotUnique silently (dedup index prevents duplicates).
  # Broadcasts to ActionCable after creation.
  def self.notify(user:, actor:, type:, notifiable: nil, metadata: {})
    return nil if user == actor

    notification = Notification.create!(
      user: user,
      actor: actor,
      notification_type: type,
      notifiable: notifiable,
      metadata: metadata
    )

    broadcast(notification)
    notification
  rescue ActiveRecord::RecordNotUnique
    nil  # Dedup index caught a duplicate — silently ignore
  end

  def self.broadcast(notification)
    html = ApplicationController.render(
      partial: 'notifications/partials/notification',
      locals: { notification: notification }
    )

    ActionCable.server.broadcast(
      "notifications_#{notification.user_id}",
      {
        event: 'new_notification',
        html: html,
        unread_count: notification.user.notifications.unread.count
      }
    )
  rescue StandardError => e
    # Don't let broadcast failures prevent notification creation.
    Rails.logger.error("[NotificationService] Broadcast failed: #{e.class} — #{e.message}")
  end
  private_class_method :broadcast
end
