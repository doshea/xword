class Admin::WordsController < ApplicationController
  before_action :ensure_admin
  before_action :find_word, only: [:edit, :update, :destroy]

  #GET /admin/words or admin_words_path
  def index
    @words = Word.all.paginate(:page => params[:page])
  end

  #GET /admin/words/:id/edit or edit_admin_word_path
  def edit
  end

  #PATCH/PUT /admin/words/:id or admin_word_path
  # AJAX #
  def update
    if @word.update_attributes(params[:word])
      alert_js('SUCCESS word updated.')
    else
      alert_js('!!!ERROR updating word!!!')
    end
  end

  #DELETE /admin/words/:id or admin_word_path
  # AJAX #
  def destroy
    if @word.destroy
      alert_js('SUCCESS word deleted.')
    else
      alert_js('!!!ERROR deleting word!!!')
    end
  end

  private

  def find_word
    @word = Word.find(params[:id])
    rescue ActiveRecord::RecordNotFound
    redirect_to :back, flash: {error: 'Sorry, that word could not be found.'}
  end

end