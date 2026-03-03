class ApplicationController < ActionController::Base
  include ActionView::Helpers::TextHelper

  protect_from_forgery with: :exception

  before_action :authenticate

  private
  def authenticate
    # cookies.signed verifies the HMAC before returning the value; returns nil
    # if the cookie is missing, expired, or has been tampered with.
    token = cookies.signed[:auth_token]
    @current_user = User.find_by_auth_token(token) if token
    # Legacy fallback: session-based auth (kept in case any old code still sets it).
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id].present?
  end

  def ensure_logged_in
    redirect_to(account_required_path) if @current_user.nil?
  end
  def ensure_admin
    redirect_to(unauthorized_path) if (@current_user.nil? || !@current_user.is_admin)
  end

  def flash_stream(message, type = 'info')
    render turbo_stream: turbo_stream.prepend("flash-alerts",
      partial: "layouts/partials/flash_alert",
      locals: { message: message, type: type })
  end

  # Convention-based lookup: derives model class from controller name (e.g., CrosswordsController → "Crossword").
  def associated_class_string
    controller_name.classify
  end
  def associated_class
    associated_class_string.constantize
  end
  def find_object
    instance_variable_set("@#{associated_class_string.underscore}", associated_class.find(params[:id]))
  rescue ActiveRecord::RecordNotFound
    redirect_back fallback_location: root_path, flash: {error: "Sorry, that #{associated_class_string.underscore.humanize} could not be found."}
  end
  def found_object
    instance_variable_get("@#{associated_class_string.underscore}")
  end

  def ensure_owner_or_admin
    obj = found_object
    unless @current_user && obj && (@current_user.is_admin || @current_user == obj.user)
      redirect_back(fallback_location: root_path, flash: {warning: "You do not own that #{associated_class_string.underscore.humanize}."})
    end
  end

end
