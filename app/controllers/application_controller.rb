include ActionView::Helpers::TextHelper

class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  rescue_from ActionController::RedirectBackError, with: :redirect_to_root

  before_action :authenticate

  private
  def authenticate
    @current_user = User.find_by_auth_token( cookies[:auth_token]) if cookies[:auth_token]
    @current_user ||= session[:user_id].present? ? User.find(session[:user_id]) : nil
  end

  def ensure_logged_in
    redirect_to(account_required_path) if @current_user.nil?
  end
  def ensure_admin
    redirect_to(unauthorized_path) if (@current_user.nil? || !@current_user.is_admin)
  end

  def redirect_to_root
    redirect_to root_path
  end

  def alert_js(s)
    render js: "alert('#{s}');"
  end

  #For use in finding generic classes and objects
  def associated_class_string
    controller_name.classify
  end
  def associated_class
    associated_class_string.constantize
  end
  def find_object
    instance_variable_set("@#{associated_class_string.downcase}", associated_class.find(params[:id]))
    rescue ActiveRecord::RecordNotFound
    redirect_to :back, flash: {error: "Sorry, that #{associated_class_string.downcase} could not be found."}
  end
  def found_object
    instance_variable_get("@#{associated_class_string.downcase}")
  end
  #
  def ensure_owner_or_admin
    if !(@current_user.is_admin or @current_user == found_object.user)
      redirect_to :back, flash: {warning: "You do not own that #{associated_class_string.downcase}."}
    end
  end

end
