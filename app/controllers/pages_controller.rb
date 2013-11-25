class PagesController < ApplicationController
  layout 'logged_out_home', only: [:welcome]

  def home
    if @current_user.nil?
      redirect_to(welcome_path)
    else
      @solved = Crossword.solved(@current_user.id).unowned(@current_user)
      in_progress = Crossword.in_progress(@current_user.id)
      @in_progress_solos = in_progress.solo
      @in_progress_teams = in_progress.teamed
      @unstarted = Crossword.unstarted(@current_user.id).unowned(@current_user)

      @owned_puzzles = @current_user.crosswords
      if @owned_puzzles.any?
        @unpublished = @owned_puzzles.unpublished
        @published = @owned_puzzles.published
      end
    end
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
    split_ways += 1 if split_ways == 0
    split_results = max_results / split_ways
    @users = @users.limit(split_results)
    @crosswords = @crosswords.limit(split_results)
    @words = @words.limit(split_results)

    @result_count = @users.count + @crosswords.count + @words.count
  end
  def welcome
    redirect_to(root_path) if @current_user.present?
    @user = User.new
  end
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
end