class CrosswordsController < ApplicationController
  before_filter :ensure_admin, only: [:index]
  before_filter :ensure_owner_or_admin, only: [:edit, :update, :destroy, :publish]

  def index
    @crosswords = Crossword.order(:created_at)
  end

  def show
    @crossword = Crossword.find(params[:id])
    if @crossword
      @solution = Solution.find_or_create_by_crossword_id_and_user_id_and_team(@crossword.id, @current_user.id, false) if @current_user
      if @solution.letters.length < (@crossword.rows * @crossword.cols)
        binding.pry
        @solution.letters = @crossword.letters.gsub(/[^_]/,' ')
        @solution.save
        binding.pry
      end
      @cells = @crossword.cells.asc_indices
    else
      #redirect to 404 page
    end
  end

  def new
    @crossword = Crossword.new
  end

  def create
    @crossword = Crossword.new(params[:crossword])
    @crossword.user = @current_user
    if @crossword.save
      @crossword.link_cells_to_neighbors
      redirect_to edit_crossword_path(@crossword)
    else
      render :new
    end
  end

  def edit
    if @crossword.published?
      redirect_to @crossword
    else
      @cells = @crossword.cells.asc_indices
      @across_cells = @crossword.across_start_cells.asc_indices
      @down_cells = @crossword.down_start_cells.asc_indices
      @across_clues = @crossword.across_clues.asc_indices
      @down_clues = @crossword.down_clues.asc_indices
    end
  end

  def update
    crossword = Crossword.find(params[:id])
    crossword.update_attributes(params[:crossword])
    render nothing: true
  end

  def destroy
    @crossword = Crossword.find(params[:id])
    @crossword.delete
  end

  def publish
    @crossword.publish
  end

  def create_team
    @crossword = Crossword.find(params[:id])
    if @crossword && @current_user
      @solution = Solution.new(
        crossword_id: @crossword.id,
        user_id: @current_user.id,
        letters: @crossword.letters.gsub(/[^_]/, ' ')
      )
      @solution.key = Solution.generate_unique_key
      @solution.team = true
      @solution.save
      redirect_to team_crossword_path(@crossword, @solution.key)
    else
      # Redirecto to some error page
    end
  end

  def team
    @crossword = Crossword.find(params[:id])
    @solution = Solution.find_by_crossword_id_and_key(params[:id], params[:key])
    if @crossword && @solution
      @team = true
      @cells = @crossword.cells.asc_indices
      if @current_user
        SolutionPartnering.find_or_create_by(solution_id: @solution.id, user_id: @current_user.id) unless (@solution.user == @current_user)
      end
      render :show
    else
      #some sort of error
    end
  end

  def favorite
    @crossword = Crossword.find(params[:id])
    if @crossword && @current_user
      unless @current_user.favorites.include? @crossword
        new_favorite = FavoritePuzzle.create
        @current_user.favorite_puzzles << new_favorite
        @crossword.favorite_puzzles << new_favorite
      end
    end
  end

  def unfavorite
    @crossword = Crossword.find(params[:id])
    if @crossword && @current_user
      existing_favorite = FavoritePuzzle.find_by_user_id_and_crossword_id(@current_user.id, @crossword.id)
      existing_favorite.delete if existing_favorite
    end
  end

  def solution_choice
    @crossword = Crossword.find(params[:id])
    @solutions = Solution.where(user_id: @current_user.id, crossword_id: @crossword.id)
    @solutions += Solution.joins(:solution_partnerings).where(crossword_id: @crossword.id, solution_partnerings: {user_id: @current_user.id}).distinct
    @solutions.sort_by!{|x| [x.team ? 1 : 0, -x.percent_complete[:numerator], Time.current - x.updated_at]}

    if @solutions.count < 1
      redirect_to @crossword
    elsif @solutions.count == 1
      redirect_to @solutions.first
    end

  end

  private
  def ensure_owner_or_admin
    @crossword = Crossword.find(params[:id])
    redirect_to(unauthorized_path) if !(@current_user.is_admin || @current_user == @crossword.user)
  end
end