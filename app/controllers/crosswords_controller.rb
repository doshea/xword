class CrosswordsController < ApplicationController
  def index
    @crosswords = Crossword.order(:created_at)
  end
  def show
    @crossword = Crossword.find(params[:id])
  end
  def new
    @crossword = Crossword.new
  end
  def edit
  end
  def create
  end
  def update
  end
  def destroy
  end
end