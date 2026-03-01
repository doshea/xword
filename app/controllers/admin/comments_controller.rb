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
  # Replaced: alert_js (jquery_ujs JS response) → redirect (Turbo follows redirect) #
  def update
    if @comment.update(update_comment_params)
      redirect_to admin_comments_path, notice: 'Comment updated.'
    else
      redirect_to edit_admin_comment_path(@comment), alert: 'Error updating comment.'
    end
  end

  #DELETE /admin/comments/:id or admin_comment_path
  # Replaced: alert_js + destroy.js.erb DOM removal → redirect to index (Turbo follows) #
  def destroy
    if @comment.destroy
      redirect_to admin_comments_path, notice: 'Comment deleted.'
    else
      redirect_to admin_comments_path, alert: 'Error deleting comment.'
    end
  end

  private

  def update_comment_params
    params.require(:comment).permit(:content, :flagged)
  end

end