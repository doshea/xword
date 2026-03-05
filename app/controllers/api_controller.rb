class ApiController < ApplicationController

  # GET /api/nyt/:year/:month/:day
  def nyt
    date_from_params
    @data = NytPuzzleFetcher.from_github(@date)

    respond_to do |format|
      format.xml  { render xml: JSON.parse(@data) }
      format.json { render json: @data.to_s }
    end
  rescue JSON::ParserError
    head :bad_gateway
  end

  # GET /api/friends — used by invite_controller.js (team invite modal)
  def friends
    return head :unauthorized unless @current_user

    render json: @current_user.friends
                   .select(:id, :first_name, :last_name, :username, :image, :deleted_at)
                   .map { |u| {
                     id: u.id,
                     username: u.username,
                     display_name: u.display_name,
                     avatar_url: u.image.present? ? u.image.search.url : ActionController::Base.helpers.asset_path('default_images/user.jpg')
                   }}
  end

  private

  def date_from_params
    @date = Date.new(params[:year].to_i, params[:month].to_i, params[:day].to_i)
  end

end
