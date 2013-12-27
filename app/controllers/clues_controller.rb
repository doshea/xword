class CluesController < ApplicationController
  def show
    @clue = Clue.find(params[:id])

    across_crosswords = @clue.across_crosswords
    down_crosswords = @clue.down_crosswords
    @count = across_crosswords.length + down_crosswords.length
    @crosswords = (across_crosswords + down_crosswords).uniq.sort{|x,y| x.title <=> y.title}
  end
  def update
    @clue = Clue.find(params[:id])
    @clue.update_attributes(params[:clue])
    render nothing: true
  end
end