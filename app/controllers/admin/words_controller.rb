class Admin::WordsController < Admin::BaseController
  def index
    # includes(:clues) prevents N+1 from word.clues.first in _words.html.haml
    @words = Word.all.includes(:clues).paginate(:page => params[:page])
  end

  private

  def resource_params
    params.require(:word).permit(:content)
  end
end
