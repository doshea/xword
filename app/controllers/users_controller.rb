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
    @user = User.new(params[:user])
    if @user.save
      session[:user_id] = @user.id unless session[:user_id]
      redirect_to root_path
    else
      render template: 'layouts/logged_out_home'
    end
  end

  #PATCH/PUT /users/:id or user_path
  def update
    @user = User.find(params[:id])
    if @user.update_attributes(params[:user])
      respond_to do |format|
        format.html { render :account }
        format.js
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
      user.generate_token(:password_reset_token)
      user.password_reset_sent_at = Time.zone.now
      user.save
      UserMailer.reset_password_email(user).deliver
    else
      #IF THERE IS NO USER
    end
  end

  #GET /users/reset_password/:password_reset_token or reset_password_users_path
  def reset_password
    @user = User.where('password_reset_sent_at > ?', 1.hours.ago).find_by(password_reset_token: params[:password_reset_token])
  end
  
  #POST /users/resetter or resetter_users_path
  def resetter
    user = User.where('password_reset_sent_at > ?', 1.hours.ago).find_by(password_reset_token: params[:password_reset_token])
    if user
      if user.update_attributes(password: params[:new_password], password_confirmation: params[:new_password_confirmation])
        user.password_reset_token = nil
        user.password_reset_sent_at = nil
        user.save
        render :password_updated
      else
        @errors = user.errors.full_messages.uniq
        render :password_errors
      end
    else
      render :redirect_back
    end
  end

  #POST /users/change_password or change_password_users_path
  def change_password
    if @current_user.authenticate(params[:old_password])
      if @current_user.update_attributes(password: params[:new_password], password_confirmation: params[:new_password_confirmation])
        render :password_updated
      else
        # things to do when the new update doesn't work, likely because it is invalid
        @errors = @current_user.errors.full_messages.uniq
        render :password_errors
      end
    else
      render :wrong_password
      #things to do when the old password is incorrect
    end
  end

  private
  # def user_not_found
  #   redirect_to error_path, flash: { error: "User \##{params[:id]} not found. :-("}
  # end

end