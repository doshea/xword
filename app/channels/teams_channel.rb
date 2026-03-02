class TeamsChannel < ApplicationCable::Channel
  def subscribed
    team_key = params[:team_key]
    if team_key.present? && Solution.exists?(key: team_key, team: true)
      stream_from "team_#{team_key}"
    else
      reject
    end
  end
end
