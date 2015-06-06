class SessionsController < ApplicationController
  
  # GET /login or login_path
  def new
    @user = User.new
  end

  # POST /login or login_path
  def create
    user = User.find_by_username(params[:username])
    if user.present? && user.authenticate(params[:password])
      # session[:user_id] = user.id
      if params[:remember_me]
        cookies.permanent[:auth_token] = user.auth_token
      else
        cookies[:auth_token] = user.auth_token
      end
      # (params[:remember_me] ? cookies.permanent[:auth_token] : cookies[:auth_token] ) = user.auth_token #replaces previous line's functionality
      redirect_to root_path
    else
      redirect_to login_path, flash: {error: 'Username/password combination did not match our records'}
    end
  end

  # DELETE /logout or logout_path
  def destroy
    session[:user_id] = nil
    cookies.delete(:auth_token)
    redirect_to root_url
  end

end
