class SessionsController < ApplicationController

  # GET /login or login_path
  def new
    @user = User.new
  end

  # POST /login or login_path
  def create
    user = User.find_by_username(params[:username])
    authenticated = begin
      user.present? && user.authenticate(params[:password])
    rescue BCrypt::Errors::InvalidHash
      # Treat corrupted password_digest as auth failure rather than 500.
      false
    end

    if authenticated
      # Store the auth_token in a signed cookie so it's HMAC-verified on every
      # read. A plain cookie can be forged by the client; signed cannot.
      # NOTE: existing plain cookies from before this change will fail the
      # signed read in ApplicationController and users will need to log in again.
      if params[:remember_me]
        cookies.permanent.signed[:auth_token] = user.auth_token
      else
        cookies.signed[:auth_token] = user.auth_token
      end
      redirect_to root_path
    else
      redirect_to login_path, flash: { error: "Username/password combination did not match our records" }
    end
  end

  # DELETE /logout or logout_path
  def destroy
    cookies.delete(:auth_token)
    redirect_to root_url
  end

end
