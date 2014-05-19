class CommentsController < ApplicationController

  #POST /comments/:id/add_comment or add_comment_path
  def add_comment
    crossword = Crossword.find(params[:id])
    user = @current_user

    if crossword && user
      @new_comment = Comment.new(content: params[:content])
      crossword.comments << @new_comment
      user.comments << @new_comment
    else
    end
  end

  #POST /comments/:id/reply or reply_to_comment
  def reply
    base_comment = Comment.find(params[:id])
    user = @current_user

    if base_comment && user
      @new_reply = Comment.new(content: params[:content])
      base_comment.replies << @new_reply
      user.comments << @new_reply
    else
    end
  end

  #DELETE /comments/:id or comment_path
  def destroy
    @comment = Comment.find params[:id]
    if @current_user && (@current_user.is_admin? || (@current_user == @comment.user))
      @comment.destroy
    else
      
    end
  end
end