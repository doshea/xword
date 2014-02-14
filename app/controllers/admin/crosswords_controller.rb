class Admin::CrosswordsController < ApplicationController
  before_filter :ensure_admin

  def index
    @crosswords = Crossword.order(:created_at).paginate(:page => params[:page])
  end

  def edit
    @crossword = Crossword.find(params[:id])
  end

  def update
    @crossword = Crossword.find(params[:id])
    @crossword.update_attributes(params[:crossword])
  end

  def destroy
    @crossword = Crossword.find(params[:id])
    @crossword.destroy
  end

end