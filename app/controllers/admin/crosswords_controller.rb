class Admin::CrosswordsController < ApplicationController
  before_action :ensure_admin

  def index
    @crosswords = Crossword.order(:created_at).paginate(:page => params[:page])
  end

  def edit
    @crossword = Crossword.find(params[:id])
  end

  def update
    @crossword = Crossword.find(params[:id])
    @crossword.update_attributes(params[:crossword])
    render nothing: :true
  end

  def destroy
    @crossword = Crossword.find(params[:id])
    @crossword.destroy
  end

end