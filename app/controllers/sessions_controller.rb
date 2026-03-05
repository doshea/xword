class SessionsController < ApplicationController
  # Pre-computed dummy digest so failed-user logins take the same time as
  # wrong-password logins (prevents username enumeration via timing oracle).
  DUMMY_DIGEST = BCrypt::Password.create("timing-oracle-dummy").freeze

  # GET /login or login_path
  def new
    @user = User.new
  end

  # POST /login or login_path
  def create
    user = User.find_by_username(params[:username])
    if user.nil?
      # Run a bcrypt comparison to match the latency of a real authenticate() call.
      BCrypt::Password.new(DUMMY_DIGEST) == params[:password]
    end
    authenticated = begin
      user.present? && user.authenticate(params[:password])
    rescue BCrypt::Errors::InvalidHash
      # Treat corrupted password_digest as auth failure rather than 500.
      false
    end

    if authenticated && user.deleted?
      redirect_to login_path, flash: { error: "This account has been deleted." }
      return
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
      redirect_to safe_redirect_path(params[:redirect])
    else
      redirect_to login_path, flash: { error: "Username/password combination did not match our records" }
    end
  end

  # DELETE /logout or logout_path
  def destroy
    @current_user&.rotate_auth_token!
    cookies.delete(:auth_token)
    redirect_to root_url
  end

end
