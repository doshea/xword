class CrosswordsController < ApplicationController
  before_filter :ensure_admin, only: [:index]
  before_filter :ensure_owner_or_admin, only: [:edit, :update, :destroy, :publish]
  def index
    @crosswords = Crossword.order(:created_at)
  end

  def show
    @crossword = Crossword.find(params[:id])
    if @crossword
      @solution = Solution.find_or_create_by_crossword_id_and_user_id(@crossword.id, @current_user.id) if @current_user
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
      @across_clues = @crossword.across_clues
      @down_clues = @crossword.down_clues
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

  private
  def ensure_owner_or_admin
    @crossword = Crossword.find(params[:id])
    redirect_to(unauthorized_path) if !(@current_user.is_admin || @current_user == @crossword.user)
  end
end