class PagesController < ApplicationController

  layout 'logged_out_home', :only => [:home]

  def home
    redirect_to(welcome_path) if @current_user.nil?
  end
  def unauthorized
  end
  def account_required
  end
  def search
    query = params[:query]
    @users = User.starts_with(query)
    @users_sliced = @users.each_slice(6)
    @crosswords = Crossword.starts_with(query)
    @crosswords_sliced = @crosswords.each_slice(4)
    @words = Word.starts_with(query)
  end
  def welcome

  end
end