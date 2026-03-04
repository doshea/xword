class FriendRequestsController < ApplicationController
  before_action :ensure_logged_in

  # POST /friend_requests
  def create
    recipient = User.find_by(id: params[:recipient_id])
    return head :not_found unless recipient
    return head :unprocessable_entity if recipient == @current_user
    return head :unprocessable_entity if @current_user.friends_with?(recipient)
    return head :unprocessable_entity if FriendRequest.where(sender_id: @current_user.id, recipient_id: recipient.id).exists?
    return head :unprocessable_entity if FriendRequest.where(sender_id: recipient.id, recipient_id: @current_user.id).exists?

    FriendRequest.create!(sender: @current_user, recipient: recipient)

    NotificationService.notify(
      user: recipient, actor: @current_user,
      type: 'friend_request'
    )

    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.replace(
        "friend-status-#{recipient.id}",
        partial: 'users/partials/friend_status',
        locals: { user: recipient, status: :pending_sent }
      )}
      format.html { redirect_to user_path(recipient) }
    end
  end

  # POST /friend_requests/accept
  def accept
    freq = FriendRequest.find_by(sender_id: params[:sender_id], recipient_id: @current_user.id)
    return head :not_found unless freq

    ActiveRecord::Base.transaction do
      Friendship.create!(user_id: freq.sender_id, friend_id: freq.recipient_id)
      # FriendRequest has id: false — destroy! would fail. Use delete_all.
      FriendRequest.where(sender_id: freq.sender_id, recipient_id: freq.recipient_id).delete_all
    end

    # Notify the original sender that their request was accepted
    sender = User.find_by(id: freq.sender_id)
    if sender
      NotificationService.notify(
        user: sender, actor: @current_user,
        type: 'friend_accepted'
      )
    end

    # Mark the friend_request notification as read
    Notification.where(user_id: @current_user.id, actor_id: params[:sender_id],
                       notification_type: 'friend_request')
                .unread.update_all(read_at: Time.current)

    respond_to do |format|
      format.html { redirect_to(safe_redirect_path(params[:redirect_to]) || notifications_path) }
    end
  end

  # DELETE /friend_requests/reject
  def reject
    # FriendRequest has id: false — use composite key lookup + delete_all.
    FriendRequest.where(sender_id: params[:sender_id], recipient_id: @current_user.id).delete_all

    # Mark the friend_request notification as read
    Notification.where(user_id: @current_user.id, actor_id: params[:sender_id],
                       notification_type: 'friend_request')
                .unread.update_all(read_at: Time.current)

    respond_to do |format|
      format.html { redirect_to notifications_path }
    end
  end
end
