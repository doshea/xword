class CommentsController < ApplicationController
  before_action :find_object, only: [:reply, :destroy]

  #POST /comments/:id/add_comment or add_comment_path
  def add_comment
    # Guard first: calling user.id before this check would crash for anonymous requests
    return head :unauthorized unless @current_user

    crossword = Crossword.find(params[:id])
    if crossword.comments.where(user_id: @current_user.id).count < Comment::MAX_PER_CROSSWORD
      @new_comment = Comment.new(content: params[:content])
      crossword.comments << @new_comment
      @current_user.comments << @new_comment
    else
      head :forbidden
    end
  end

  #POST /comments/:id/reply or reply_to_comment
  def reply
    # @comment set by find_object before_action; assign to @base_comment for turbo stream template DOM IDs
    @base_comment = @comment

    if @current_user
      @new_reply = Comment.new(content: params[:content])
      @base_comment.replies << @new_reply
      @current_user.comments << @new_reply
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