class CommentsController < ApplicationController
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

  def destroy
    @comment = Comment.find params[:id]
    if @current_user && (@current_user.is_admin? || (@current_user == @comment.user))
      @comment.delete
    else
      
    end
  end
end