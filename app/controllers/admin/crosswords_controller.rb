class Admin::CrosswordsController < ApplicationController
  before_action :ensure_admin
  before_action :find_object, only: [:edit, :update, :destroy, :generate_preview]

  #GET /admin/crosswords or admin_crosswords_path
  def index
    @crosswords = Crossword.order(:created_at).paginate(page: params[:page])
  end

  #GET /admin/crosswords/:id/edit or edit_admin_crossword_path
  def edit
  end

  #PATCH/PUT /admin/crosswords/:id or admin_crossword_path
  # Replaced: alert_js (jquery_ujs JS response) → redirect (Turbo follows redirect) #
  def update
    if @crossword.update(update_crossword_params)
      redirect_to admin_crosswords_path, notice: 'Crossword updated.'
    else
      redirect_to edit_admin_crossword_path(@crossword), alert: 'Error updating crossword.'
    end
  end

  #DELETE /admin/crosswords/:id or admin_crossword_path
  # Replaced: alert_js + destroy.js.erb DOM removal → redirect to index (Turbo follows) #
  def destroy
    if @crossword.destroy
      redirect_to admin_crosswords_path, notice: 'Crossword deleted.'
    else
      redirect_to admin_crosswords_path, alert: 'Error deleting crossword.'
    end
  end

  # Replaced: button_to with remote: true → now button_to redirects via Turbo
  def generate_preview
    @crossword.generate_preview
    redirect_to edit_admin_crossword_path(@crossword), notice: 'Preview generated.'
  end

  private
  def update_crossword_params
    params.require(:crossword).permit(:title, :rows, :cols, :published, :circled, :description, :letters)
  end

end