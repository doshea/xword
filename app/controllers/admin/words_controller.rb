class Admin::WordsController < ApplicationController
  before_action :ensure_admin

  #GET /admin/words or admin_words_path
  def index
    @words = Word.all.paginate(:page => params[:page])
  end

  #GET /admin/words/:id/edit or edit_admin_word_path
  def edit
    @word = Word.find(params[:id])
  end

  #PATCH/PUT /admin/words/:id or admin_word_path
  def update
    @word = Word.find(params[:id])
    @word.update_attributes(params[:word])
  end


  #DELETE /admin/words/:id or admin_word_path
  def destroy
    @word = Word.find(params[:id])
    @word.destroy
  end

end