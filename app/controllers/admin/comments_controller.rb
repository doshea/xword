class Admin::CommentsController < ApplicationController
  before_action :ensure_admin
  before_action :find_object, only: [:edit, :update, :destroy]

  #GET /admin/comments or admin_comments_path
  def index
    @comments = Comment.all.paginate(:page => params[:page])
  end

  #GET /admin/comments/:id/edit or edit_admin_comment_path
  def edit
  end

  #PATCH/PUT /admin/comments/:id or admin_comment_path
  # AJAX #
  def update
    if @comment.update_attributes(update_comment_params)
      alert_js('SUCCESS comment updated.')
    else
      alert_js('ERROR updating comment.')
    end
  end

  #DELETE /admin/comments/:id or admin_comment_path
  # AJAX #
  def destroy
    if @comment.destroy
      alert_js('SUCCESS comment deleted.')
    else
      alert_js('ERROR deleting comment.')
    end  
  end

  private

  def update_comment_params
    params.require(:comment).permit(:content, :flagged)
  end

end