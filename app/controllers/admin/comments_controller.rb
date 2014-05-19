class Admin::CommentsController < ApplicationController
  before_action :ensure_admin

  #GET /admin/comments or admin_comments_path
  def index
    @comments = Comment.all.paginate(:page => params[:page])
  end

  #GET /admin/comments/:id/edit or edit_admin_comment_path
  def edit
    @comment = Comment.find(params[:id])
  end

  #PATCH/PUT /admin/comments/:id or admin_comment_path
  def update
    @comment = Comment.find(params[:id])
    @comment.update_attributes(params[:comment])
  end

  #DELETE /admin/comments/:id or admin_comment_path
  def destroy
    @comment = Comment.find(params[:id])
    @comment.destroy
  end

end