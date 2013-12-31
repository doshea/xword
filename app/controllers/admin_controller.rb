class AdminController < ApplicationController
  before_filter :ensure_admin
  def email

  end
  def test_emails
  end

  def cloning_tank
  end

  def user_search
    relevant_params = params[:user].select{|k,v| !v.blank?}
    @users = User.where(relevant_params)
  end
  def clone_user
    user = User.find params[:id]
    cookies[:auth_token] = user.auth_token
    redirect_to root_path
  end

  def users
    @users = User.order(:created_at)
  end

  def crosswords
    @crosswords = Crossword.order(:created_at)
  end

  def words
    @words = Word.all
  end

  def clues
    @clues = Clue.all
  end

  def comments
    @comments = Comment.all
  end

end