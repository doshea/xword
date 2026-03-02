class Admin::CommentsController < Admin::BaseController
  def index
    # includes prevents N+1 from comment.user, comment.crossword, and comment.base_comment.crossword in _comments.html.haml
    @comments = Comment.all.includes(:user, :crossword, base_comment: :crossword).paginate(:page => params[:page])
  end

  private

  def resource_params
    params.require(:comment).permit(:content, :flagged)
  end
end
