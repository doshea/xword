class Admin::CrosswordsController < ApplicationController
  before_action :ensure_admin
  before_action :find_object, only: [:edit, :update, :destroy, :generate_preview]

  #GET /admin/crosswords or admin_crosswords_path
  def index
    @crosswords = Crossword.order(:created_at).paginate(:page => params[:page])
  end

  #GET /admin/crosswords/:id/edit or edit_admin_crossword_path
  def edit
  end

  #PATCH/PUT /admin/crosswords/:id or admin_crossword_path
  # AJAX #
  def update
    if @crossword.update_attributes(update_crossword_params)
      alert_js('SUCCESS crossword updated.')
    else
      alert_js('!!!ERROR updating crossword!!!')
    end
  end

  #DELETE /admin/crosswords/:id or admin_crossword_path
  # AJAX #
  def destroy
    if @crossword.destroy
      alert_js('SUCCESS crossword deleted.')
    else
      alert_js('!!!ERROR deleting crossword!!!')
    end
  end

  def generate_preview
    @crossword.generate_preview
  end

  private
  def update_crossword_params
    params.require(:crossword).permit(:title, :rows, :cols, :published, :circled, :description, :letters)
  end

end