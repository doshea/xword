class NotificationsController < ApplicationController
  before_action :ensure_logged_in

  # GET /notifications
  def index
    @notifications = @current_user.notifications
                                  .includes(:actor)
                                  .recent
  end

  # PATCH /notifications/:id/mark_read
  def mark_read
    @notification = @current_user.notifications.find_by(id: params[:id])
    return head :not_found unless @notification

    @notification.update!(read_at: Time.current) if @notification.read_at.nil?

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to notifications_path }
    end
  end

  # PATCH /notifications/mark_all_read
  def mark_all_read
    @current_user.notifications.unread.update_all(read_at: Time.current)

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to notifications_path }
    end
  end
end
