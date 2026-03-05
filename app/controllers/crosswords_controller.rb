class CrosswordsController < ApplicationController
  before_action :find_object, only: [:show, :team, :favorite, :unfavorite, :solution_choice, :check_cell, :check_completion, :admin_fake_win, :admin_reveal_puzzle, :reveal]
  before_action :ensure_logged_in, only: [:create_team, :favorite, :unfavorite]
  before_action :ensure_admin, only: [:admin_fake_win, :admin_reveal_puzzle]

  #GET /crosswords/:id or crossword_path
  def show
    if @current_user
      @solution = begin
        Solution.find_or_create_by(
          crossword_id: @crossword.id,
          user_id: @current_user.id,
          team: false
        )
      rescue ActiveRecord::RecordNotUnique
        Solution.find_by(crossword_id: @crossword.id, user_id: @current_user.id, team: false)
      end
      @solution.fill_letters
      # Single EXISTS query instead of loading all favorites into memory twice in the view.
      @is_favorited = @current_user.favorites.exists?(@crossword.id)
      # Detect if user has multiple solutions (own + team partnerships) for "Switch solution" link
      solution_count = Solution.where(user_id: @current_user.id, crossword_id: @crossword.id).count +
                       Solution.joins(:solution_partnerings)
                               .where(crossword_id: @crossword.id, solution_partnerings: { user_id: @current_user.id })
                               .count
      @has_multiple_solutions = solution_count > 1
      @revealed_set = Set.new(JSON.parse(@solution.revealed_indices))
    end
    # Preload stats to avoid N+1 association .count calls in _puzzle_stats.html.haml.
    @word_count = @crossword.across_clues.count + @crossword.down_clues.count
    @solver_count = @crossword.solutions.count
    # Preload comment authors and replies (+ reply authors) to avoid N+1 in _comment.html.haml.
    @comments = @crossword.comments.includes(:user, replies: :user)
    @cells = @crossword.cells.asc_indices
  end

  #POST /crosswords/:id/team or create_team_crossword_path
  def create_team
    @crossword = Crossword.find_by(id: params[:id])
    if @crossword && @current_user
      existing_team = @current_user.solutions.find_by(crossword_id: @crossword.id, team: true)
      return redirect_to team_crossword_path(@crossword, existing_team.key) if existing_team

      preexisting_letters = @current_user.solutions
                              .where(team: false, crossword_id: @crossword.id)
                              .first.try(:letters)
      @solution = Solution.new(
        crossword_id: @crossword.id,
        user_id:      @current_user.id,
        team:         true,
        letters:      preexisting_letters || @crossword.letters.gsub(/[^_]/, " ")
      )
      # assign_team_key (before_create) sets key via SecureRandom.alphanumeric(12).
      # Rescue handles the astronomically unlikely collision caught by the DB unique index.
      begin
        @solution.save!
      rescue ActiveRecord::RecordNotUnique
        retry
      end
      redirect_to team_crossword_path(@crossword, @solution.key)
    else
      redirect_to root_path, flash: { error: "Unable to create team session." }
    end
  end

  #GET /crosswords/:id/team/:key or team_crossword_path
  def team
    @solution = Solution.find_by_crossword_id_and_key(params[:id], params[:key])
    if @crossword && @solution
      @team = true
      @word_count = @crossword.across_clues.count + @crossword.down_clues.count
      @solver_count = @crossword.solutions.count
      @cells = @crossword.cells.asc_indices
      @comments = @crossword.comments.includes(:user, replies: :user)
      if @current_user
        @is_favorited = @current_user.favorites.exists?(@crossword.id)
        begin
          SolutionPartnering.find_or_create_by(solution_id: @solution.id, user_id: @current_user.id) unless (@solution.user == @current_user)
        rescue ActiveRecord::RecordNotUnique
          # Unique index caught duplicate — safe to ignore
        end
      end
      render :show
    else
      redirect_to root_path, flash: { error: "That team session could not be found." }
    end
  end

  #POST /crosswords/:id/favorite or favorite_crossword_path
  def favorite
    if @crossword && @current_user
      fav = begin
        FavoritePuzzle.find_or_create_by(user_id: @current_user.id, crossword_id: @crossword.id)
      rescue ActiveRecord::RecordNotUnique
        FavoritePuzzle.find_by(user_id: @current_user.id, crossword_id: @crossword.id)
      end
      if fav.persisted?
        render :favorite_unfavorite
      else
        flash_stream('You have already favorited that crossword.')
      end
    end
  end

  #DELETE /crosswords/:id/favorite or favorite_crossword_path
  def unfavorite
    if @crossword && @current_user
      existing_favorite = FavoritePuzzle.find_by_user_id_and_crossword_id(@current_user.id, @crossword.id)
      if existing_favorite
        if existing_favorite.destroy
          render :favorite_unfavorite
        else
          flash_stream('There was an error removing this crossword from favorites.', 'error')
        end
      else
        flash_stream('That crossword is not in your favorites.')
      end
    end
  end

  #GET /crosswords/:id/solution_choice or solution_choice_crossword_path
  def solution_choice
    if @current_user
      @solutions = Solution.includes(:user, :teammates).where(user_id: @current_user.id, crossword_id: @crossword.id).to_a
      @solutions += Solution.includes(:user, :teammates).joins(:solution_partnerings).where(crossword_id: @crossword.id, solution_partnerings: {user_id: @current_user.id}).distinct
      @solutions.sort_by!{|x| [x.team ? 1 : 0, -x.percent_complete[:numerator], Time.current - x.updated_at]}

      if @solutions.count < 1
        return redirect_to @crossword
      elsif @solutions.count == 1
        return redirect_to @solutions.first
      end
    else
      redirect_to @crossword
    end
  end

  #POST /crosswords/:id/check_cell or check_cell_crossword_path
  def check_cell
    indices = params[:indices]&.map(&:to_i)
    @mismatches = @crossword.cell_mismatches(params[:letters], indices: indices)
    respond_to do |f|
      f.json { render json: { mismatches: @mismatches } }
      f.js   # Legacy: check_cell.js.erb
    end
  end

  #POST /crosswords/:id/check_completion or check_completion_crossword_path
  def check_completion
    @correctness = (@crossword.letters == params[:letters])
    if @current_user && params[:solution_id].present?
      @solution = @current_user.solutions.find_by(id: params[:solution_id], crossword_id: @crossword.id)
      # Team partners don't own the solution — find via partnership
      @solution ||= Solution.joins(:solution_partnerings)
                      .where(solution_partnerings: { user_id: @current_user.id })
                      .find_by(id: params[:solution_id], crossword_id: @crossword.id)
    end
    if @correctness && @current_user && @solution
      @has_commented = @current_user.comments.where(crossword_id: @solution.crossword_id).exists?
    end
    # Find a next puzzle to suggest on win
    if @correctness
      @next_puzzle = if @current_user
                       # Subquery avoids PG DISTINCT + ORDER BY RANDOM() conflict
                       Crossword.where(id: Crossword.new_to_user(@current_user))
                                .order("RANDOM()").first
                     else
                       Crossword.where.not(id: @crossword.id).order("RANDOM()").first
                     end
    end
    respond_to do |f|
      f.json do
        result = { correct: @correctness }
        if @correctness
          result[:win_modal_html] = render_to_string(
            partial: 'solutions/partials/win_modal_contents',
            formats: [:html]
          )
        end
        render json: result
      end
      f.js # Legacy: check_completion.js.erb
    end
  end

  # POST /crosswords/:id/admin_fake_win — Admin-only: trigger win modal without completing puzzle
  def admin_fake_win
    @correctness = true
    if params[:solution_id].present?
      @solution = @current_user.solutions.find_by(id: params[:solution_id], crossword_id: @crossword.id)
      @solution ||= Solution.joins(:solution_partnerings)
                      .where(solution_partnerings: { user_id: @current_user.id })
                      .find_by(id: params[:solution_id], crossword_id: @crossword.id)
    end
    @has_commented = @current_user.comments.where(crossword_id: @crossword.id).exists? if @solution

    render json: {
      correct: true,
      win_modal_html: render_to_string(
        partial: 'solutions/partials/win_modal_contents',
        formats: [:html]
      )
    }
  end

  # POST /crosswords/:id/admin_reveal_puzzle — Admin-only: return correct letters
  def admin_reveal_puzzle
    render json: { letters: @crossword.letters }
  end

  # POST /crosswords/:id/reveal
  # Returns correct letters for the requested cell indices.
  # Tracks hints on the user's solution if logged in.
  def reveal
    indices = Array(params[:indices]).map(&:to_i)
    return head :bad_request if indices.empty?

    # Build { index => correct_letter } for requested positions only
    revealed = {}
    indices.each do |i|
      next if i < 0 || i >= @crossword.letters.length
      letter = @crossword.letters[i]
      next if letter == '_' # void cell — nothing to reveal
      revealed[i] = letter
    end

    # Track hints and persist revealed indices (logged-in users only)
    if @current_user && params[:solution_id].present? && revealed.any?
      solution = @current_user.solutions.find_by(id: params[:solution_id], crossword_id: @crossword.id)
      solution ||= Solution.joins(:solution_partnerings)
                           .where(solution_partnerings: { user_id: @current_user.id })
                           .find_by(id: params[:solution_id], crossword_id: @crossword.id)
      if solution
        solution.increment!(:hints_used, revealed.size)
        existing = JSON.parse(solution.revealed_indices)
        merged = (existing + revealed.keys).uniq
        solution.update_column(:revealed_indices, merged.to_json)
      end
    end

    render json: { letters: revealed }
  end

end
