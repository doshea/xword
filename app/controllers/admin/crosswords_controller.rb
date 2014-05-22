class Admin::CrosswordsController < ApplicationController
  before_action :ensure_admin
  before_action :find_crossword, only: [:edit, :update, :destroy]

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
    if @crossword.update_attributes(params[:crossword])
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

  private

  def find_crossword
    @crossword = Crossword.find(params[:id])
    rescue ActiveRecord::RecordNotFound
    redirect_to :back, flash: {error: 'Sorry, that crossword could not be found.'}
  end

end