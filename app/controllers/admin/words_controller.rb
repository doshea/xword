class Admin::WordsController < ApplicationController
  before_action :ensure_admin
  before_action :find_object, only: [:edit, :update, :destroy]

  #GET /admin/words or admin_words_path
  def index
    # includes(:clues) prevents N+1 from word.clues.first in _words.html.haml
    @words = Word.all.includes(:clues).paginate(:page => params[:page])
  end

  #GET /admin/words/:id/edit or edit_admin_word_path
  def edit
  end

  #PATCH/PUT /admin/words/:id or admin_word_path
  # Replaced: alert_js (jquery_ujs JS response) → redirect (Turbo follows redirect) #
  def update
    if @word.update(update_word_params)
      redirect_to admin_words_path, notice: 'Word updated.'
    else
      redirect_to edit_admin_word_path(@word), alert: 'Error updating word.'
    end
  end

  #DELETE /admin/words/:id or admin_word_path
  # Replaced: alert_js + destroy.js.erb DOM removal → redirect to index (Turbo follows) #
  def destroy
    if @word.destroy
      redirect_to admin_words_path, notice: 'Word deleted.'
    else
      redirect_to admin_words_path, alert: 'Error deleting word.'
    end
  end

  private
  def update_word_params
    params.require(:word).permit(:content)
  end

end