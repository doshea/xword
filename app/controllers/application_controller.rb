class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :authenticate


  private
  def authenticate
    # @current_user = session[:user_id].present? ? User.find(session[:user_id]) : nil
    @current_user = User.find_by_auth_token( cookies[:auth_token]) if cookies[:auth_token]
  end

  def ensure_logged_in
    redirect_to(account_required_path) if @current_user.nil?
  end
  def ensure_admin
    redirect_to(unauthorized_path) if (@current_user.nil? || !@current_user.is_admin)
  end
end