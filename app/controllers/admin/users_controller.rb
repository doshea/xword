class Admin::UsersController < ApplicationController
  before_filter :ensure_admin

  def index
    @users = User.order(:created_at).paginate(:page => params[:page])
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
  end

end