class PagesController < ApplicationController
  layout 'logged_out_home', only: [:welcome]

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
  def live_search
    max_results = 15

    query = params[:query]
    @users = User.starts_with(query).limit(max_results)
    @crosswords = Crossword.starts_with(query).limit(max_results)
    @words = Word.starts_with(query).limit(max_results)

    split_ways = (@users.any? ? 1 : 0) + (@crosswords.any? ? 1 : 0) + (@words.any? ? 1 : 0)
    split_results = max_results / split_ways
    @users = @users.limit(split_results)
    @crosswords = @crosswords.limit(split_results)
    @words = @words.limit(split_results)

    @result_count = @users.count + @crosswords.count + @words.count
  end
  def welcome
    redirect_to(root_path) if @current_user.present?
  end
end