class WordsController < ApplicationController
  before_filter :ensure_admin, only: [:index]

  def index
    @words = Word.all
  end
  def show
    @word = Word.find(params[:id])
  end
end