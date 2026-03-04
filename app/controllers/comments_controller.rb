class CommentsController < ApplicationController
  before_action :find_object, only: [:reply, :destroy]

  #POST /comments/:id/add_comment or add_comment_path
  def add_comment
    # Guard first: calling user.id before this check would crash for anonymous requests
    return head :unauthorized unless @current_user

    crossword = Crossword.find_by(id: params[:id])
    return head :not_found unless crossword
    if crossword.comments.where(user_id: @current_user.id).count < Comment::MAX_PER_CROSSWORD
      @new_comment = Comment.new(content: params[:content], crossword: crossword, user: @current_user)
      return head :unprocessable_entity unless @new_comment.save
    else
      head :forbidden
    end
  end

  #POST /comments/:id/reply or reply_to_comment
  def reply
    # @comment set by find_object before_action; assign to @base_comment for turbo stream template DOM IDs
    @base_comment = @comment
    return head :unauthorized unless @current_user
    return head :unprocessable_entity if @base_comment.base_comment_id.present?  # Don't allow replies to replies

    @new_reply = Comment.new(content: params[:content], user: @current_user)
    @base_comment.replies << @new_reply
    return head :unprocessable_entity unless @new_reply.persisted?
  end

  #DELETE /comments/:id or comment_path
  def destroy
    if @current_user && (@current_user.is_admin? || (@current_user == @comment.user))
      @comment.destroy
    else
      head :forbidden
    end
  end

end
