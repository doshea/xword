class CreateController < ApplicationController

  #GET /create/dashboard or create_dashboard_path
  def dashboard
    @unpublished = @current_user.unpublished_crosswords
    @published = @current_user.crosswords
  end
end