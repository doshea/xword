class Admin::CrosswordsController < ApplicationController
  before_action :ensure_admin

  #GET /admin/crosswords or admin_crosswords_path
  def index
    @crosswords = Crossword.order(:created_at).paginate(:page => params[:page])
  end

  #GET /admin/crosswords/:id/edit or edit_admin_crossword_path
  def edit
    @crossword = Crossword.find(params[:id])
  end

  #PATCH/PUT /admin/crosswords/:id or admin_crossword_path
  def update
    @crossword = Crossword.find(params[:id])
    @crossword.update_attributes(params[:crossword])
    render nothing: :true
  end

  #DELETE /admin/crosswords/:id or admin_crossword_path
  def destroy
    @crossword = Crossword.find(params[:id])
    @crossword.destroy
  end

end