class UsersController < ApplicationController
  before_action :ensure_logged_in, only: [:account]
  # TODO Fix this
  # rescue_from ActiveRecord::Error::RecordNotFound with: :user_not_found

  #GET /users/:id or user_path
  def show
    begin
      @user = User.find(params[:id])
    rescue
      redirect_to error_path(prev: request.original_url), flash: {error: "Could not find User \##{params[:id]}"}
    end
  end

  #GET /users/new or new_user_path
  def new
    @user = User.new
  end

  #POST /users or users_path
  def create
    @user = User.new(create_user_params)
    if @user.save
      session[:user_id] = @user.id unless session[:user_id]
      redirect_to root_path
    else
      error_messages = @user.errors.full_messages.uniq
      error_count = error_messages.length
      form_error = "There #{error_count > 1 ? 'were' : 'was' } #{pluralize(error_count, 'error')} signing up:"
      redirect_to new_user_path, flash: {form_errors: error_messages, form_error: form_error}
    end
  end

  #PATCH/PUT /users/:id or user_path
  def update
    @user = User.find(params[:id])
    if @user.update(update_user_params)
      respond_to do |format|
        format.turbo_stream  # Renders users/update.turbo_stream.erb (replaces profile pic element)
        format.html { render :account }
      end
    else
      #HANDLE THE FAILURE CASE
    end
  end

  #GET /users/account or account_users_path
  #TODO: should there be a separate account controller?
  def account
    @user = @current_user
  end

  #GET /users/forgot_password or forgot_password_users_path
  def forgot_password
    @user = @current_user
    @redirect = params[:redirect]
  end

  #POST /users/send_password_reset or send_password_reset_users_path
  def send_password_reset
    user = @current_user || User.find_by(email: params[:email]) || User.find_by(username: params[:username])
    if user
      # Rails 8.1 has_secure_password generates password_reset_token automatically
      # (signed from password_salt — no DB storage needed; expiry handled by signed token)
      UserMailer.reset_password_email(user).deliver_now
    end
    respond_to do |format|
      format.turbo_stream  # Renders users/send_password_reset.turbo_stream.erb (shows confirmation message)
      format.html { redirect_to forgot_password_users_path, notice: 'Password reset email sent if account found.' }
    end
  end

  #GET /users/reset_password/:password_reset_token or reset_password_users_path
  def reset_password
    # Rails 8.1: find_by_password_reset_token verifies the signed token and checks expiry
    @user = User.find_by_password_reset_token(params[:password_reset_token])
  end

  #POST /users/resetter or resetter_users_path
  def resetter
    # Rails 8.1: find_by_password_reset_token returns nil if token is expired or invalid
    user = User.find_by_password_reset_token(params[:password_reset_token])
    if user
      if user.update(password: params[:new_password], password_confirmation: params[:new_password_confirmation])
        # Changing the password invalidates the old signed token automatically (password_salt changes)
        # Replaced: render :password_updated (jquery_ujs JS response clearing fields + slideDown success)
        # Now: HTTP redirect — Turbo follows it and user sees account page with flash notice
        redirect_to account_users_path, notice: 'Password updated successfully.'
      else
        @errors = user.errors.full_messages.uniq
        respond_to do |format|
          format.turbo_stream { render :password_errors }  # Renders users/password_errors.turbo_stream.erb
          format.html { render :reset_password }
        end
      end
    else
      # Replaced: render :redirect_back (jquery_ujs JS window.location redirect)
      # Now: HTTP redirect to reset password page — Turbo follows it
      redirect_to reset_password_users_path(params[:password_reset_token])
    end
  end

  #POST /users/change_password or change_password_users_path
  def change_password
    if @current_user.authenticate(params[:old_password])
      if @current_user.update(password: params[:new_password], password_confirmation: params[:new_password_confirmation])
        # Replaced: render :password_updated (jquery_ujs JS response clearing fields + slideDown success)
        # Now: HTTP redirect — Turbo follows it and user sees account page with flash notice
        redirect_to account_users_path, notice: 'Password updated successfully.'
      else
        @errors = @current_user.errors.full_messages.uniq
        respond_to do |format|
          format.turbo_stream { render :password_errors }  # Renders users/password_errors.turbo_stream.erb
          format.html { render :account }
        end
      end
    else
      respond_to do |format|
        format.turbo_stream { render :wrong_password }  # Renders users/wrong_password.turbo_stream.erb
        format.html { render :account }
      end
    end
  end

  private
  def create_user_params
    params.require(:user).permit(:username, :email, :password, :password_confirmation)
  end
  def update_user_params
    params.require(:user).permit(:first_name, :last_name, :password, :password_confirmation)
  end

end