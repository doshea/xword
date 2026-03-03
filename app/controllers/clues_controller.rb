class CluesController < ApplicationController
  before_action :find_object
  before_action :ensure_logged_in, only: [:update]
  before_action :ensure_clue_owner, only: [:update]

  #GET /clue/:id or clue_path
  def show
    @crosswords = @clue.crosswords_by_title
    return redirect_to error_path if @crosswords.empty?
    @count = @clue.across_crosswords.size + @clue.down_crosswords.size
  end

  #PATCH/PUT /clue/:id or clue_path
  # NOTE: Does not update phrase_id — phrases are linked at publish time only.
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
