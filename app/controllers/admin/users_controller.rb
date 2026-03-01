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
  # Replaced: alert_js (jquery_ujs JS response) → redirect (Turbo follows redirect) #
  def update
    if @user.update(update_user_params)
      redirect_to admin_users_path, notice: 'User updated.'
    else
      redirect_to edit_admin_user_path(@user), alert: 'Error updating user.'
    end
  end

  #DELETE /admin/users/:id or admin_user_path
  # Replaced: alert_js + destroy.js.erb DOM removal → redirect to index (Turbo follows) #
  def destroy
    if @user.destroy
      redirect_to admin_users_path, notice: 'User deleted.'
    else
      redirect_to admin_users_path, alert: 'Error deleting user.'
    end
  end

  private
  def update_user_params
    params.require(:user).permit(:username, :email, :image, :remote_image_url, :is_admin, :location)
  end

end