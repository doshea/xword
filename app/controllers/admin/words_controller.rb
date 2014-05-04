class Admin::WordsController < ApplicationController
  before_action :ensure_admin

  def index
    @words = Word.all.paginate(:page => params[:page])
  end

  def edit
    @word = Word.find(params[:id])
  end

  def update
    @word = Word.find(params[:id])
    @word.update_attributes(params[:word])
  end

  def destroy
    @word = Word.find(params[:id])
    @word.destroy
  end

end