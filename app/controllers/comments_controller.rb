class CommentsController < ApplicationController
  before_action :find_object, only: [:reply, :destroy]

  #POST /comments/:id/add_comment or add_comment_path
  def add_comment
    user = @current_user
    crossword = Crossword.find params[:id]
    previous_comment_count = crossword.comments.where(user_id: user.id).count

    if crossword
      if user
        if previous_comment_count < Comment::MAX_PER_CROSSWORD
          @new_comment = Comment.new(content: params[:content])
          crossword.comments << @new_comment
          user.comments << @new_comment
        else
          head :forbidden
        end
      else
        head :unauthorized
      end
    else
      head :bad_request
    end
  end

  #POST /comments/:id/reply or reply_to_comment
  def reply
    user = @current_user
    base_comment = Comment.find(params[:id])

    if base_comment && user
      @new_reply = Comment.new(content: params[:content])
      base_comment.replies << @new_reply
      user.comments << @new_reply
    else
    end
  end

  #DELETE /comments/:id or comment_path
  def destroy
    if @current_user && (@current_user.is_admin? || (@current_user == @comment.user))
      @comment.destroy
    else
      
    end
  end

end