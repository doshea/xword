class UsersController < ApplicationController
  before_filter :ensure_admin, :only => [:index]

  def index
    @users = User.order(:created_at)
  end

  def show
    @user = User.find(params[:id])
  end

  def new
    @user = User.new
  end

  def account
    @user = @current_user
  end
end