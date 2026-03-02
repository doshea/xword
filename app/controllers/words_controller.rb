class WordsController < ApplicationController
  before_action :find_object, only: [:show]
  
  #GET /words/:id or word_path
  def show
    @crosswords = @word.crosswords_by_title
    @count = @word.across_crosswords.size + @word.down_crosswords.size
    @clues = @word.clues.sort_by(&:difficulty)
  end

  #POST /words/match or match_words_path
  def match
    pattern = params[:pattern].to_s.strip
    @results = pattern.present? ? Word.word_match(pattern.gsub(/_|-/, '?')).map(&:upcase) : []
  end
end