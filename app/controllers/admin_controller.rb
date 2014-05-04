class AdminController < ApplicationController
  before_action :ensure_admin
  def email

  end
  def test_emails
  end

  def cloning_tank
  end

  def user_search
    @users = User.admin_search(params[:query])
  end
  def clone_user
    user = User.find params[:id]
    cookies[:auth_token] = user.auth_token
    redirect_to root_path
  end
  def wine_comment
  end

end