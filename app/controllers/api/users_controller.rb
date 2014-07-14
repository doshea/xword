class Api::UsersController < ApplicationController

  def index
    users = User.all
    render json: users.map{|user| api_attributes(user)}
  end

  def search
    user = User.find_by(username: params[:username])
    render json: api_attributes(user)
  end

  private
  def api_attributes(user)
    acceptable_keys = [:first_name, :last_name, :username, :created_at]
    user.attributes.symbolize_keys.delete_if{|k,v| !k.in? acceptable_keys}
  end

end