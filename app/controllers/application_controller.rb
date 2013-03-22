class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :authenticate


  private
  def authenticate
    @current_user = User.find(session[:user_id]) if session[:user_id].present?
  end

  def ensure_logged_in
    redirect_to(root_path) if @current_user.nil?
  end
  def ensure_admin
    redirect_to(unauthorized_path) if (@current_user.nil? || !@current_user.is_admin)
  end
end