class CreateController < ApplicationController
  before_action :ensure_logged_in

  #GET /create/dashboard or create_dashboard_path
  def dashboard
    @unpublished = @current_user.unpublished_crosswords.order(updated_at: :desc)
    @published = @current_user.crosswords.order(updated_at: :desc)
  end
end
