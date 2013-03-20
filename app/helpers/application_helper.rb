module ApplicationHelper

  def is_admin?
    @current_user.present? && @current_user.is_admin
  end

  def is_logged_in?
    @current_user.present?
  end
end
