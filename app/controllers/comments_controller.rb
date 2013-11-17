class CommentsController < ApplicationController
  def index
    @comments = Comment.all
  end
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
end