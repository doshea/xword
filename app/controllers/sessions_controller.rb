class SessionsController < ApplicationController

  def new
  end

  def create
    user = User.where(:username => params[:username]).first
    if user.present? && user.authenticate(params[:password])
      session[:user_id] = user.id
      redirect_to root_path
    else
      flash[:notice] = "Invalid email/password combination"
      render "new"
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_url, :notice => "Logged out!"
  end
end