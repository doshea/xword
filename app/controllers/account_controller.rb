class AccountController < ApplicationController
  before_action :ensure_logged_in, only: [:show, :update, :change_password]

  def show
  end

  def update
    @current_user.update(profile_params)
    redirect_to account_path
  end

  def change_password
    if @current_user.authenticate(params[:old_password])
      @current_user.update(password_params)
    end
    redirect_to account_path
  end

  def verify
    @user = User.find_by_verification_token(params[:verification_token])
    if @user
      @user.update_attribute(:verified, true)
      cookies.signed[:auth_token] = @user.auth_token
      redirect_to account_verified_path
    else
      redirect_to root_path, alert: 'Invalid verification link.'
    end
  end

  def verified
  end

  private ###
  def profile_params
    params.require(:user).permit(:first_name, :last_name, :image)
  end
  def password_params
    params.require(:user).permit(:password, :password_confirmation)
  end

end
