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
    sender = User.find_by(id: params[:sender_id])
    return head :not_found unless sender

    begin
      FriendshipService.accept(sender: sender, recipient: @current_user)
    rescue ActiveRecord::RecordNotFound
      return head :not_found
    end

    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.replace(
        "friend-status-#{sender.id}",
        partial: 'users/partials/friend_status',
        locals: { user: sender, status: :friends }
      )}
      format.html { redirect_to(safe_redirect_path(params[:redirect_to]) || notifications_path) }
    end
  end

  # DELETE /friend_requests/unfriend
  def unfriend
    friend = User.find_by(id: params[:friend_id])
    return head :not_found unless friend

    FriendshipService.unfriend(user: @current_user, friend: friend)

    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.replace(
        "friend-status-#{friend.id}",
        partial: 'users/partials/friend_status',
        locals: { user: friend, status: :none }
      )}
      format.html { redirect_to user_path(friend) }
    end
  end

  # DELETE /friend_requests/reject
  def reject
    sender = User.find_by(id: params[:sender_id])
    return head :not_found unless sender

    FriendshipService.reject(sender: sender, recipient: @current_user)

    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.replace(
        "friend-status-#{sender.id}",
        partial: 'users/partials/friend_status',
        locals: { user: sender, status: :none }
      )}
      format.html { redirect_to notifications_path }
    end
  end
end
