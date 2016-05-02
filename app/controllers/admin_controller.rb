class AdminController < ApplicationController
  before_action :ensure_admin
  
  #GET /admin/email or admin_email_path
  def email
  end

  #POST /admin/test_emails or admin_test_emails_path
  def test_emails
  end

  #GET /admin/clone_user or admin_cloning_tank_path
  def cloning_tank
  end

  def cheat
  end

  def manual_nyt

  end

  def create_manual_nyt
    if params[:nyt_text]
      Crossword.add_nyt_puzzle(JSON.parse(params[:nyt_text]))
    end
  end

  #POST /admin/user_search or admin_user_search_path
  def user_search
    @users = User.admin_search(params[:query])
  end

  #POST /admin/clone_user or admin_clone_user_path
  def clone_user
    user = User.find params[:id]
    cookies[:auth_token] = user.auth_token
    redirect_to root_path
  end

  #GET /admin/wine_comment or admin_wine_comment_path
  def wine_comment
  end

end