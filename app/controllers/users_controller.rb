class UsersController < ApplicationController
  before_filter :ensure_admin, only: [:index]
  before_filter :ensure_logged_in, only: [:account]

  def index
    @users = User.order(:created_at)
  end

  def show
    @user = User.find(params[:id])
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(params[:user])
    if @user.save
      session[:user_id] = user.id unless session[:user_id]
      redirect_to root_path
    else
      render template: 'layouts/logged_out_home'
    end
  end

  def update
    @current_user.update_attributes(params[:user])
    render :account
  end

  def account
    @user = @current_user
  end
end