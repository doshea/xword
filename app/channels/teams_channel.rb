class TeamsChannel < ApplicationCable::Channel
  def subscribed
    stream_from "team_#{params[:team_key]}"
  end
end
