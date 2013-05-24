class SessionsController < ApplicationController
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
      gflash success: {value: true, title: 'Login', time: 1400}
      redirect_to root_path
    else
      gflash error: {value: true, title: 'Login Failed', time: 5000}
      redirect_to welcome_path
    end
  end

  def destroy
    session[:user_id] = nil
    cookies.delete(:auth_token)
    gflash success: {value: true, title: 'Logout', time: 2000}
    redirect_to root_url
  end
end
