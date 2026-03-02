class PagesController < ApplicationController
  layout 'logged_out_home', only: [:welcome]
  before_action :find_nytimes_user, only: [:nytimes, :user_made]

  #GET /errors or error_path
  def error
  end

  #GET / or root_path
  def home
    if @current_user
      per = Crossword.per_page
      @unstarted_count   = Crossword.new_to_user(@current_user).count
      @in_progress_count = Crossword.all_in_progress(@current_user).count
      @solved_count      = Crossword.all_solved(@current_user).count
      @unstarted   = Crossword.new_to_user(@current_user).includes(:user).limit(per)
      @in_progress = Crossword.all_in_progress(@current_user).includes(:user).limit(per)
      @solved      = Crossword.all_solved(@current_user).includes(:user).limit(per)
    else
      @unstarted = Crossword.all.includes(:user).paginate(page: params[:page])
      @unstarted_count = @unstarted.total_entries
    end
  end

  #GET /unauthorized or unauthorized_path
  def unauthorized
  end

  #GET /account_required or account_required_path
  def account_required
    @redirect = params[:redirect]
    # redirect_to send_password_reset_users_path(redirect: url_for({controller: :pages, action: :account_required, only_path: false}).html_safe)
  end

  #GET /faq or faq_path
  def faq
  end

  #GET /search or search_path
  def search
    @query = params[:query]
    @users = User.starts_with(@query)
    @users_sliced = @users.each_slice(6)
    @crosswords = Crossword.starts_with(@query).includes(:user)
    @crosswords_sliced = @crosswords.each_slice(4)
    @words = Word.starts_with(@query)
  end

  #GET /live_search or live_search_path
  def live_search
    query = params[:query]
    max_results = 15
    @users = User.starts_with(query).limit(max_results).load
    @crosswords = Crossword.starts_with(query).limit(max_results).load
    @words = Word.starts_with(query).limit(max_results).load

    split_ways = (@users.any? ? 1 : 0) + (@crosswords.any? ? 1 : 0) + (@words.any? ? 1 : 0)
    split_ways += 1 if split_ways == 0
    split_results = max_results / split_ways
    @users = @users.first(split_results)
    @crosswords = @crosswords.first(split_results)
    @words = @words.first(split_results)

    @result_count = @users.size + @crosswords.size + @words.size
  end

  #GET /welcome or welcome_path
  def welcome
    redirect_to(root_path) if @current_user.present?
    @user = User.new
  end

  #GET /stats or stats_path
  def stats
    non_unq_signup_dates = User.pluck(:created_at).map{|time_with_zone| time_with_zone.to_date}.sort
    unq_signup_dates = non_unq_signup_dates.uniq
    @days_operational = (unq_signup_dates.first..Date.today)

    date_counts = Hash.new(0)
    non_unq_signup_dates.each {|date| date_counts[date] += 1}

    @signup_counts = []
    @days_operational.each {|day| @signup_counts << (date_counts[day] || 0)}

    @running_signup_counts = @signup_counts.each_with_index.map { |x,i| @signup_counts[0..i].inject(:+) }

  end

  #GET /nytimes or nytimes_path
  #TODO decide if this will be its own page or not
  def nytimes
    @nytimes_puzzles = @nytimes_user ? @nytimes_user.crosswords.includes(:user) : Crossword.none
  end

  #GET /user_made or user_made_path
  #TODO decide if this will be its own page or not
  def user_made
    @user_puzzles = @nytimes_user ? Crossword.where.not(user_id: @nytimes_user.id).includes(:user) : Crossword.includes(:user).all
  end

  private

  def find_nytimes_user
    @nytimes_user = User.find_by_username('nytimes')
  end
end