class CrosswordsController < ApplicationController
  before_filter :ensure_admin, only: [:index]
  before_filter :ensure_owner_or_admin, only: [:edit, :update, :destroy]
  def index
    @crosswords = Crossword.order(:created_at)
  end
  def show
    @crossword = Crossword.find(params[:id])
    if @crossword
      @solution = Solution.find_or_create_by_crossword_id_and_user_id(@crossword.id, @current_user.id) if @current_user
      @clue_instances = @crossword.clue_instances.order('is_across DESC').order('start_cell ASC')
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
      redirect_to edit_crossword_path(@crossword)
    else
      render :new
    end
  end
  def edit

    redirect_to(unauthorized_path) if !(@current_user.is_admin || @current_user == @crossword.user)
  end
  def update

  end
  def destroy

  end

  private
  def ensure_owner_or_admin
    @crossword = Crossword.find(params[:id])
    redirect_to(unauthorized_path) if !(@current_user.is_admin || @current_user == @crossword.user)
  end
end