class WordsController < ApplicationController
  before_filter :ensure_admin, only: [:index]

  def index
    @words = Word.all
  end
  def show
    @word = Word.find(params[:id])

    across_crosswords = @word.across_crosswords
    down_crosswords = @word.down_crosswords
    @count = across_crosswords.length + down_crosswords.length
    @crosswords = (across_crosswords + down_crosswords).uniq.sort{|x,y| x.title <=> y.title}

    @clues = @word.clues.sort{|x,y| x.difficulty <=> y.difficulty}
  end
end