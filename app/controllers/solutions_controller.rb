class SolutionsController < ApplicationController
  # Guard runs before find_object so an invalid/null ID from stale JS never triggers a flash error
  prepend_before_action :guard_null_solution_id, only: [:update]
  before_action :find_object, only: [:show, :update, :get_incorrect, :destroy,
    :team_update, :join_team, :leave_team, :roll_call, :send_team_chat, :show_team_clue]
  before_action :ensure_logged_in, only: [:destroy, :team_update, :join_team, :leave_team, :roll_call, :send_team_chat, :show_team_clue]
  before_action :ensure_solution_access, only: [:update, :get_incorrect]
  before_action :ensure_team_member, only: [:team_update, :join_team, :leave_team, :roll_call, :send_team_chat, :show_team_clue]
  before_action :ensure_owner_or_partner, only: [:destroy]

  #GET /solutions/:id or solution_path
  def show
    unless @solution.crossword
      redirect_to root_path, alert: "This puzzle is no longer available."
      return
    end
    if @solution.team
      if @current_user && ((@current_user == @solution.user) || SolutionPartnering.where(solution_id: @solution.id, user_id: @current_user.id).any?)
        redirect_to team_crossword_path(@solution.crossword.id, @solution.key)
      else
        head :forbidden
      end
    else
      redirect_to @solution.crossword
    end
  end

  #PATCH/PUT /solutions/:id or solution_path
  def update
    @solution.letters = params[:letters]
    @save_counter = params[:save_counter]
    @solution.save
    respond_to { |f| f.js }
  end

  #POST /solutions/:id/get_incorrect or get_incorrect_solution_path
  # get_incorrect.js.erb was all commented-out dead code; replaced with head :ok
  def get_incorrect
    unless @solution.crossword
      head :not_found
      return
    end
    @mismatches = @solution.crossword.get_mismatches(params[:letters])
    if @mismatches.empty?
      @solution.update(is_complete: true)
    end
    head :ok
  end

  #PATCH /solutions/:id/team_update or team_update_solution_path
  def team_update
    data = {
                row: params[:row],
                col: params[:col],
                letter: params[:letter],
                solver_id: params[:solver_id],
                red: params[:red],
                green: params[:green],
                blue: params[:blue],
                server_time: Process.clock_gettime(Process::CLOCK_REALTIME, :millisecond)
                }

    team_broadcast(@solution, { event: 'change_cell' }.merge(data))

    head :ok
  end

  #POST /solutions/:id/join_team or join_team_solution_path
  def join_team
    data = {
            display_name: params[:display_name],
            solver_id: params[:solver_id],
            red: params[:red],
            green: params[:green],
            blue: params[:blue]
            }
    team_broadcast(@solution, { event: 'join_puzzle' }.merge(data))
    head :ok
  end

  #POST /solutions/:id/leave_team or leave_team_solution_path
  def leave_team
    data = {solver_id: params[:solver_id]}
    team_broadcast(@solution, { event: 'leave_puzzle' }.merge(data))
    head :ok
  end

  #POST /solutions/:id/roll_call or roll_call_solution_path
  def roll_call
    team_broadcast(@solution, { event: 'roll_call' })
    head :ok
  end

  #POST /solutions/:id/send_team_chat or send_team_chat_solution_path
  def send_team_chat
    data = {display_name: params[:display_name],
                avatar: params[:avatar],
                chat_text: params[:chat]}
    @broadcast_failed = !team_broadcast(@solution, { event: 'chat_message' }.merge(data))
    respond_to do |format|
      format.turbo_stream  # Renders solutions/send_team_chat.turbo_stream.erb (resets team chat form)
      format.html { redirect_to team_crossword_path(@solution.crossword, @solution.key) }
    end
  end

  #POST /solutions/:id/show_team_clue or show_team_clue_solution_path
  def show_team_clue
    data = {cell_num: params[:cell_num],
                across: params[:across],
                red: params[:red],
                green: params[:green],
                blue: params[:blue],
                solver_id: params[:solver_id]
                }
    team_broadcast(@solution, { event: 'outline_team_clue' }.merge(data))
    head :ok
  end

  # If the user is a partner on the solution, delete their partnership. If they are the owner, delete the solution.
  #DELETE /solutions/:id or delete_solution_path
  def destroy
    if @solution_partnering
      @solution_partnering.destroy
    else
      @solution.destroy
    end
    redirect_to :root
  end

  private

  # Broadcast to the team's ActionCable channel; returns true on success, false on Redis failure.
  def team_broadcast(solution, payload)
    ActionCable.server.broadcast("team_#{solution.key}", payload)
    true
  rescue Redis::BaseConnectionError
    Rails.logger.warn("ActionCable broadcast failed (Redis unavailable)")
    false
  end

  # Silently absorbs PUT /solutions/null requests sent by stale JS when solution_id is not yet set.
  # The JS guard in save_solution() should prevent this, but this is the server-side safety net.
  def guard_null_solution_id
    head :ok if params[:id].to_i <= 0
  end

  # Verify the current user owns the solution or is a team partner.
  # Runs after find_object (which sets @solution). Returns 403 for
  # unauthenticated or unauthorized users — appropriate for AJAX endpoints.
  def ensure_solution_access
    return head(:forbidden) unless @current_user
    return if @current_user == @solution.user
    return if SolutionPartnering.exists?(solution_id: @solution.id, user_id: @current_user.id)
    head :forbidden
  end

  def ensure_team_member
    return if @current_user == @solution.user
    return if SolutionPartnering.exists?(solution_id: @solution.id, user_id: @current_user.id)
    head :forbidden
  end

  def ensure_owner_or_partner
    return redirect_to(unauthorized_path) unless @current_user
    @solution_partnering = SolutionPartnering.find_by_user_id_and_solution_id(@current_user.id, @solution.id)
    redirect_to(unauthorized_path) if !((@current_user == @solution.user) || (@solution_partnering))
  end
end
