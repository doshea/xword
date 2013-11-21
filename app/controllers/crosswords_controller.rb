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
      @crossword.link_cells
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
        user_id: @current_user.id
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
      render :show
    else
      #some sort of error
    end
  end

  private
  def ensure_owner_or_admin
    @crossword = Crossword.find(params[:id])
    redirect_to(unauthorized_path) if !(@current_user.is_admin || @current_user == @crossword.user)
  end
end