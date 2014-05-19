class Admin::UsersController < ApplicationController
  before_action :ensure_admin

  #GET /admin/users or admin_users_path
  def index
    @users = User.order(:created_at).paginate(:page => params[:page])
  end

  #GET /admin/users/:id/edit or edit_admin_user_path
  def edit
    @user = User.find(params[:id])
  end

  #PATCH/PUT /admin/users/:id or admin_user_path
  def update
    @user = User.find(params[:id])
    @user.update_attributes(params[:user])
  end

  #DELETE /admin/users/:id or admin_user_path
  def destroy
    @user = User.find(params[:id])
    @user.destroy
  end

end