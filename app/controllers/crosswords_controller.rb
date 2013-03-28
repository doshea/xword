class CrosswordsController < ApplicationController
  before_filter :ensure_admin, :only => [:index]
  def index
    @crosswords = Crossword.order(:created_at)
  end
  def show
    @crossword = Crossword.find(params[:id])
    @clue_instances = @crossword.clue_instances.order('is_across DESC').order('start_cell ASC')
  end
  def new
    @crossword = Crossword.new
  end
  def create
    @crossword = Crossword.new(params[:crossword])
    if @crossword.save
      redirect_to edit_crossword_path(@crossword)
    else
      render :new
    end
  end
  def edit
    @crossword = Crossword.find(params[:id])
  end
  def update
  end
  def destroy
  end
end