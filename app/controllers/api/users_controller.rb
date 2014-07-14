class Api::UsersController < ApplicationController

  def search
    user = User.find_by(username: params[:username])
    render json: api_attributes(user)
  end

  private
  def api_attributes(user)
    acceptable_keys = [:first_name, :last_name, :username, :image, :created_at]
    user.attributes.symbolize_keys.delete_if{|k,v| !k.in? acceptable_keys}
  end

end