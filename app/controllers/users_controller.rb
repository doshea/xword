class UsersController < ApplicationController
  before_action :ensure_logged_in, only: [:account, :update, :change_password]

  #GET /users/:id or user_path
  def show
    @user = User.find_by(id: params[:id])
    unless @user
      return redirect_to error_path(prev: request.original_url),
                         flash: { error: "Could not find User \##{params[:id]}" }
    end
    @crosswords = @user.crosswords.paginate(page: params[:puzzles_page], per_page: 10)
    @crossword_count = @user.crosswords.count
    @comments   = @user.comments.order_recent
                       .includes(:crossword, base_comment: [:crossword, { base_comment: :crossword }])
                       .paginate(page: params[:comments_page], per_page: 10)
    @is_friend  = !!(@current_user && @current_user != @user &&
                     @current_user.friends_with?(@user))
  end

  #GET /users/new or new_user_path
  def new
    @user = User.new
  end

  #POST /users or users_path
  def create
    @user = User.new(create_user_params)
    if @user.save
      cookies.signed[:auth_token] = @user.auth_token
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
    @user = User.find_by(id: params[:id])
    unless @user
      return redirect_to(error_path(prev: request.original_url), flash: { error: "Could not find User \##{params[:id]}" })
    end
    unless @current_user == @user || @current_user.is_admin
      return redirect_to(unauthorized_path)
    end
    if @user.update(update_user_params)
      respond_to do |format|
        format.turbo_stream  # Renders users/update.turbo_stream.erb (replaces profile pic element)
        format.html { render :account }
      end
    else
      redirect_to account_users_path, flash: { error: 'There was a problem updating your profile.' }
    end
  end

  #GET /users/account or account_users_path
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
      # Rails 8.1 signed token: no DB storage needed; expiry built into signature.
      begin
        UserMailer.reset_password_email(user).deliver_now
      rescue Net::SMTPAuthenticationError, Net::SMTPServerBusy, Net::SMTPFatalError,
             Net::SMTPSyntaxError, Net::SMTPUnknownError, Net::OpenTimeout,
             Net::ReadTimeout, IOError, Errno::ECONNREFUSED => e
        Rails.logger.error("[send_password_reset] Email delivery failed: #{e.class} — #{e.message}")
      end
    end
    redirect_to forgot_password_users_path, flash: { success: 'If an account was found, you should receive a password reset email shortly.' }
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
        redirect_to account_users_path, flash: { success: 'Password updated successfully.' }
      else
        @errors = user.errors.full_messages.uniq
        respond_to do |format|
          format.turbo_stream { render :password_errors }  # Renders users/password_errors.turbo_stream.erb
          format.html { render :reset_password }
        end
      end
    else
      redirect_to forgot_password_users_path, flash: { error: 'That password reset link has expired. Please request a new one.' }
    end
  end

  #POST /users/change_password or change_password_users_path
  def change_password
    if @current_user.authenticate(params[:old_password])
      if @current_user.update(password: params[:new_password], password_confirmation: params[:new_password_confirmation])
        redirect_to account_users_path, flash: { success: 'Password updated successfully.' }
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
    params.require(:user).permit(:first_name, :last_name, :location, :image, :remote_image_url, :password, :password_confirmation)
  end

end
