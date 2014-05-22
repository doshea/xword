class CluesController < ApplicationController
  before_action :find_clue

  #GET /clue/:id or clue_path
  def show
    across_crosswords = @clue.across_crosswords
    down_crosswords = @clue.down_crosswords
    @count = across_crosswords.length + down_crosswords.length
    @crosswords = (across_crosswords + down_crosswords).uniq.sort{|x,y| x.title <=> y.title}
  end

  #PATCH/PUT /clue/:id or clue_path
  def update
    @clue.update_attributes(params[:clue])
    render nothing: true
  end


  private

  def find_clue
    @clue = Clue.find(params[:id])
  end
end