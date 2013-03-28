class PagesController < ApplicationController

  layout 'logged_out_home', :only => [:home]

  def home
  end
  def unauthorized
  end
  def account_required
  end
  def search
    query = params[:query]
    @users = User.starts_with(query)
    @crosswords = Crossword.starts_with(query)
    @words = Word.starts_with(query)
  end
end