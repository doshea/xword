class Api::UsersController < ApplicationController

  def index
    users = User.select(:id, :first_name, :last_name, :username, :created_at)
    render json: users.map{|user| api_attributes(user)}
  end

  def search
    user = User.find_by(username: params[:username])
    return head :not_found unless user
    render json: api_attributes(user)
  end

  # GET /api/users/friends
  def friends
    return head :unauthorized unless @current_user

    render json: @current_user.friends.select(:id, :first_name, :last_name, :username, :image)
                               .map { |u| {
                                 id: u.id,
                                 username: u.username,
                                 display_name: u.display_name,
                                 avatar_url: u.image.present? ? u.image.search.url : ActionController::Base.helpers.asset_path('default_images/user.jpg')
                               }}
  end

  private
  def api_attributes(user)
    acceptable_keys = [:first_name, :last_name, :username, :created_at]
    user.attributes.symbolize_keys.delete_if{|k,v| !k.in? acceptable_keys}
  end

end
