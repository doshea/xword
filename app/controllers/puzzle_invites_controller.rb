class PuzzleInvitesController < ApplicationController
  before_action :ensure_logged_in

  # POST /puzzle_invites
  def create
    solution = Solution.find_by(id: params[:solution_id])
    return head :not_found unless solution&.team?

    invitee = User.find_by(id: params[:user_id])
    return head :not_found unless invitee
    return head :unprocessable_entity unless @current_user.friends_with?(invitee)

    crossword = solution.crossword
    team_path = team_crossword_path(crossword, solution.key)

    NotificationService.notify(
      user: invitee, actor: @current_user,
      type: 'puzzle_invite', notifiable: solution,
      metadata: {
        crossword_id: crossword&.id,
        crossword_title: crossword&.title,
        team_path: team_path
      }
    )

    head :ok
  end
end
