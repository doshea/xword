class Admin::UsersController < ApplicationController
  before_action :ensure_admin
  before_action :find_object, only: [:edit, :update, :destroy]

  #GET /admin/users or admin_users_path
  def index
    @users = User.order(:created_at).paginate(:page => params[:page])
  end

  #GET /admin/users/:id/edit or edit_admin_user_path
  def edit
  end

  #PATCH/PUT /admin/users/:id or admin_user_path
  # AJAX #
  def update
    if @user.update(update_user_params)
      alert_js('SUCCESS user updated.')
    else
      alert_js('!!!ERROR updating user!!!')
    end
  end

  #DELETE /admin/users/:id or admin_user_path
  # AJAX #
  def destroy
    if @user.destroy
      alert_js('SUCCESS user deleted.')
    else
      alert_js('!!!ERROR deleting user!!!')
    end
  end

  private
  def update_user_params
    params.require(:user).permit(:username, :email, :image, :remote_image_url, :is_admin, :location)
  end

end