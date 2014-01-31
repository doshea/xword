class Admin::WordsController < ApplicationController
  before_filter :ensure_admin

  def index
    @words = Word.all.paginate(:page => params[:page])
  end

  def edit
    @word = Word.find(params[:id])
  end

  def update
    @word = Word.find(params[:id])
  end

end