class UsersController < ApplicationController
  before_filter :ensure_admin, :only => [:index]
  before_filter :ensure_logged_in, :only => [:account]

  MAX_EMAIL_LENGTH = 25
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email,
    :presence => true,
    :uniqueness => true,
    :length => { :maximum => MAX_EMAIL_LENGTH, :message => ": That's just too long. Your email shouldn't be above #{MAX_EMAIL_LENGTH} characters" },
    :format => { with: VALID_EMAIL_REGEX, :message => ": Only real email addresses, please" }

  def index
    @users = User.order(:created_at)
  end

  def show
    @user = User.find(params[:id])
  end

  def new
    @user = User.new
  end

  def create
    user = User.new(params[:user])
    if user.save
      session[:user_id] = user.id
      redirect_to root_path
    else
      render :new
    end
  end

  def update
    @current_user.update_attributes(params[:user])
    render :account
  end

  def account
    @user = @current_user
  end
end