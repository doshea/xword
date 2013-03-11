class UsersController < ApplicationController
  def index
    @users = User.order(:created_at)
  end

  def new
    @user = User.new
  end
end