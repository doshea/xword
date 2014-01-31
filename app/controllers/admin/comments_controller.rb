class Admin::CommentsController < ApplicationController
  before_filter :ensure_admin

  def index
    @comments = Comment.all.paginate(:page => params[:page])
  end

  def edit
    @comment = Comment.find(params[:id])
  end

  def update
    @comment = Comment.find(params[:id])
    @comment.update_attributes(params[:comment])
  end

  def destroy
    @comment = Comment.find(params[:id])
    @comment.destroy
  end

end