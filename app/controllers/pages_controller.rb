class PagesController < ApplicationController
  layout 'logged_out_home', only: [:welcome]

  def error
  end

  def home
    if @current_user.nil?
      redirect_to(welcome_path)
    else
      @owned_puzzles = @current_user.crosswords

      unowned_published = Crossword.published.standard - @owned_puzzles
      @nonstandard = Crossword.published.nonstandard

      @solved_solo = Crossword.standard.solved(@current_user.id).solo.unowned(@current_user).distinct
      not_solved_solo = unowned_published - @solved_solo
      @in_progress_solo = Crossword.standard.in_progress(@current_user.id).distinct & not_solved_solo
      published_not_solo = not_solved_solo - @in_progress_solo


      my_partnerings = @current_user.solution_partnerings.map{|par| {sol: par.solution, cw: par.crossword}}
      my_partnerings_solved = my_partnerings.select{|par| par[:sol].is_complete}.map{|par| par[:cw]}.uniq
      my_partnerings_in_progress = my_partnerings.select{|par| !par[:sol].is_complete}.map{|par| par[:cw]}.uniq

      @solved_team = published_not_solo & (Crossword.standard.solved(@current_user.id).teamed.unowned(@current_user).distinct | my_partnerings_solved)
      @solved = (@solved_solo | @solved_team).sort{|x, y| y.date_published <=> x.date_published}
      available_in_progress_team = published_not_solo - @solved_team
      @in_progress_team = available_in_progress_team & (Crossword.standard.in_progress(@current_user.id).teamed.unowned(@current_user).distinct | my_partnerings_in_progress)

      @unstarted = available_in_progress_team - @in_progress_team


      if @owned_puzzles.any?
        @unpublished = @owned_puzzles.unpublished
        @published = @owned_puzzles.published
      end
    end
  end

  def unauthorized
  end

  def account_required
    @redirect = params[:redirect]
    # redirect_to send_password_reset_users_path(redirect: url_for({controller: :pages, action: :account_required, only_path: false}).html_safe)
  end

  def faq
  end

  def search
    @query = params[:query]
    @users = User.starts_with(@query)
    @users_sliced = @users.each_slice(6)
    @crosswords = Crossword.starts_with(@query)
    @crosswords_sliced = @crosswords.each_slice(4)
    @words = Word.starts_with(@query)
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
  def nytimes
    @nytimes_user = User.find_by_username('nytimes')
    @nytimes_puzzles = @nytimes_user.crosswords.published
  end


end