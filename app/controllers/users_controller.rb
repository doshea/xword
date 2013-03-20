class UsersController < ApplicationController
  def index
    @users = User.order(:created_at)
  end

  def show
    @user = User.find(params[:id])
  end

  def new
    @user = User.new
  end
end