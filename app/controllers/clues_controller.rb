class CluesController < ApplicationController
  before_action :find_object

  #GET /clue/:id or clue_path
  def show
    across_crosswords = @clue.across_crosswords
    down_crosswords = @clue.down_crosswords
    @count = across_crosswords.length + down_crosswords.length
    @crosswords = (across_crosswords + down_crosswords).uniq.sort{|x,y| x.title <=> y.title}
  end

  #PATCH/PUT /clue/:id or clue_path
  def update
    @clue.update(clue_params)
    head :ok
  end

  private
  def clue_params
    params.require(:clue).permit(:content)
  end
end