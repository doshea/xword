class CluesController < ApplicationController
  before_action :find_object
  before_action :ensure_logged_in, only: [:update]
  before_action :ensure_clue_owner, only: [:update]

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

  def ensure_clue_owner
    crossword = @clue.across_crosswords.first || @clue.down_crosswords.first
    return if @current_user && crossword && (@current_user == crossword.user || @current_user.is_admin)
    head :forbidden
  end
end
