class CrosswordsController < ApplicationController
  before_action :find_object, only: [:show, :team, :favorite, :unfavorite, :solution_choice, :check_cell, :check_completion]
  before_action :ensure_logged_in, only: [:create_team, :favorite, :unfavorite]

  #GET /crosswords/:id or crossword_path
  def show
    if @current_user
      @solution = Solution.find_or_create_by(
        crossword_id: @crossword.id,
        user_id: @current_user.id,
        team: false
      )
      @solution.fill_letters
      # Single EXISTS query instead of loading all favorites into memory twice in the view.
      @is_favorited = @current_user.favorites.exists?(@crossword.id)
    end
    # Preload comment authors and replies (+ reply authors) to avoid N+1 in _comment.html.haml.
    @comments = @crossword.comments.includes(:user, replies: :user)
    @cells = @crossword.cells.asc_indices
  end

  #POST /crosswords/:id/team or create_team_crossword_path
  def create_team
    @crossword = Crossword.find_by(id: params[:id])
    if @crossword && @current_user
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
      @cells = @crossword.cells.asc_indices
      @comments = @crossword.comments.includes(:user, replies: :user)
      if @current_user
        @is_favorited = @current_user.favorites.exists?(@crossword.id)
        SolutionPartnering.find_or_create_by(solution_id: @solution.id, user_id: @current_user.id) unless (@solution.user == @current_user)
      end
      render :show
    else
      redirect_to root_path, flash: { error: "That team session could not be found." }
    end
  end

  #POST /crosswords/:id/favorite or favorite_crossword_path
  def favorite
    if @crossword && @current_user
      if @current_user.favorites.exists?(@crossword.id)
        alert_js('You have already favorited that crossword.')
      else
        if FavoritePuzzle.create(user_id: @current_user.id, crossword_id: @crossword.id)
          render :favorite_unfavorite
        end
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
          alert_js('There was an error removing this crossword from favorites.')
        end
      else
        alert_js('That crossword is not in your favorites.')
      end
    end
  end

  #GET /crosswords/:id/solution_choice or solution_choice_crossword_path
  def solution_choice
    if @current_user
      @solutions = Solution.where(user_id: @current_user.id, crossword_id: @crossword.id)
      @solutions += Solution.joins(:solution_partnerings).where(crossword_id: @crossword.id, solution_partnerings: {user_id: @current_user.id}).distinct
      @solutions.sort_by!{|x| [x.team ? 1 : 0, -x.percent_complete[:numerator], Time.current - x.updated_at]}

      if @solutions.count < 1
        redirect_to @crossword
      elsif @solutions.count == 1
        redirect_to @solutions.first
      end
    else
      redirect_to @crossword
    end
  end

  #GET /crosswords/batch or batch_crosswords_path
  #TODO fix the batching links so they can't be too long. Right now the "Next 12" button can throw a long URI error
  def batch
    @crosswords = Crossword.where(id: params[:ids])
    @crosswords_remaining = @crosswords[Crossword.per_page..-1]
    @crosswords = @crosswords[0...Crossword.per_page]
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

end
