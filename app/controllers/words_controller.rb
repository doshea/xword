class WordsController < ApplicationController
  before_action :find_object, only: [:show]
  
  #GET /words/:id or word_path
  def show
    across_crosswords = @word.across_crosswords
    down_crosswords = @word.down_crosswords
    @count = across_crosswords.length + down_crosswords.length
    @crosswords = (across_crosswords + down_crosswords).uniq.sort{|x,y| x.title <=> y.title}

    @clues = @word.clues.sort{|x,y| x.difficulty <=> y.difficulty}
  end

  #POST /words/match or match_words_path
  def match
    @results = Word.word_match(params[:pattern].gsub(/_|-/, '?')).map(&:upcase)
  end
end