class CreateController < ApplicationController

  #GET /create/dashboard or create_dashboard_path
  def dashboard
    @unpublished = @current_user.try(:unpublished_crosswords)
    @published = @current_user.try(:crosswords)
  end
end