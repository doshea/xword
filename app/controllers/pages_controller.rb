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
      @unstarted   = Crossword.new_to_user(@current_user).order(created_at: :desc).includes(:user).limit(per)
      @in_progress = Crossword.all_in_progress(@current_user).order(created_at: :desc).includes(:user).limit(per)
      @solved      = Crossword.all_solved(@current_user).order(created_at: :desc).includes(:user).limit(per)
    else
      @unstarted = Crossword.all.order(created_at: :desc).includes(:user).paginate(page: params[:page])
      @unstarted_count = @unstarted.total_entries
    end
  end

  # POST /home/load_more
  # Returns Turbo Stream: appends next page of puzzle cards, updates load-more button.
  def load_more
    page = [params[:page].to_i, 1].max
    per = Crossword.per_page
    scope_name = params[:scope]

    scope = if @current_user
              case scope_name
              when 'unstarted'   then Crossword.new_to_user(@current_user)
              when 'in_progress' then Crossword.all_in_progress(@current_user)
              when 'solved'      then Crossword.all_solved(@current_user)
              else return head :bad_request
              end
            else
              return head :bad_request unless scope_name == 'unstarted'
              Crossword.all
            end

    @total      = scope.count
    @crosswords = scope.order(created_at: :desc).includes(:user)
                       .offset((page - 1) * per).limit(per)
    @list_id    = "#{scope_name.dasherize}-list"
    @scope      = scope_name
    @next_page  = page + 1
    @remaining  = [@total - (page * per), 0].max
    @has_more   = @remaining > 0
  end

  #GET /unauthorized or unauthorized_path
  def unauthorized
  end

  #GET /account_required or account_required_path
  def account_required
    @redirect = params[:redirect]
  end

  #GET /about or about_path
  def about
  end

  #GET /contact or contact_path
  def contact
  end

  #GET /faq or faq_path
  def faq
  end

  #GET /search or search_path
  def search
    @query = params[:query]
    @users = User.starts_with(@query).load
    @crosswords = Crossword.starts_with(@query).includes(:user).load
    @words = Word.starts_with(@query).includes(:clues).load
  end

  #GET /live_search or live_search_path
  # Splits max_results evenly across non-empty categories so one type doesn't crowd others.
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
    respond_to do |f|
      f.json do
        result = { result_count: @result_count }
        if @result_count > 0
          result[:html] = render_to_string(
            partial: 'layouts/partials/live_results',
            formats: [:html]
          )
        end
        render json: result
      end
      f.js # Legacy: live_search.js.erb
    end
  end

  #GET /random or random_puzzle_path
  def random_puzzle
    crossword = if @current_user
                  Crossword.unowned(@current_user).order("RANDOM()").first
                else
                  Crossword.order("RANDOM()").first
                end
    if crossword
      redirect_to crossword
    else
      redirect_to root_path, flash: { info: "No puzzles found." }
    end
  end

  #GET /welcome or welcome_path
  def welcome
    return redirect_to(root_path) if @current_user.present?
    @user = User.new
  end

  #GET /stats or stats_path
  def stats
    date_counts = User.group("DATE(created_at)").order("DATE(created_at)").count
    return redirect_to(root_path, flash: { info: "No data yet." }) if date_counts.empty?

    @days_operational = (date_counts.keys.first..Date.today)
    @signup_counts = @days_operational.map { |day| date_counts[day] || 0 }

    running = 0
    @running_signup_counts = @signup_counts.map { |c| running += c }
  end

  #GET /nytimes or nytimes_path
  def nytimes
    @nytimes_puzzles = @nytimes_user ? @nytimes_user.crosswords.order(created_at: :desc).includes(:user) : Crossword.none
  end

  #GET /user_made or user_made_path
  def user_made
    @user_puzzles = @nytimes_user ? Crossword.where.not(user_id: @nytimes_user.id).order(created_at: :desc).includes(:user) : Crossword.order(created_at: :desc).includes(:user).all
  end

  private

  def find_nytimes_user
    @nytimes_user = User.find_by_username('nytimes')
  end
end