class Admin::UsersController < ApplicationController
  before_action :ensure_admin
  before_action :find_user, only: [:edit, :update, :destroy]

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
    if @user.update_attributes(params[:user])
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

  def find_user
    @user = User.find(params[:id])
    rescue ActiveRecord::RecordNotFound
    redirect_to :back, flash: {error: 'Sorry, that user could not be found.'}
  end

end