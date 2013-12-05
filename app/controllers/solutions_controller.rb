class SolutionsController < ApplicationController

  def show
    solution = Solution.find(params[:id])
    if solution.team
      if (@current_user == solution.user) || (SolutionPartnering.where(solution_id: solution.id, user_id: @current_user.id).any?)
        redirect_to team_crossword_path(solution.crossword.id, solution.key)
      else
        render :nothing
      end
    else
      redirect_to solution.crossword
    end
  end

  def update
    solution = Solution.find(params[:id])
    solution.letters = params[:letters]
    solution.save
  end
  def get_incorrect
    @solution = Solution.find(params[:id])
    @mismatches = @solution.crossword.return_mismatches(params[:letters])
    if @mismatches.empty?
      @solution.update_attributes(is_complete: true)
    end
  end
  def check_correctness
    @correctness = Solution.find(params[:id]).crossword.letters == params[:letters]
  end

  def team_update
    data = {
                row: params[:row],
                col: params[:col],
                letter: params[:letter],
                solver_id: params[:solver_id],
                red: params[:red],
                green: params[:green],
                blue: params[:blue]
                }

    Pusher.trigger(params[:channel], 'change_cell', data)

    render nothing: true
  end
  def join_team
    data = {
                display_name: params[:display_name],
                solver_id: params[:solver_id],
                red: params[:red],
                green: params[:green],
                blue: params[:blue]
                }
    Pusher.trigger(params[:channel], 'join_puzzle', data)
    render nothing: true
  end
  def leave_team
    data = {
                solver_id: params[:solver_id]
                }
    Pusher.trigger(params[:channel], 'leave_puzzle', data)
    render nothing: true
  end
  def roll_call
    data = {}
    Pusher.trigger(params[:channel], 'roll_call', data)
    render nothing: true
  end
  def send_team_chat
    data = {display_name: params[:display_name],
                avatar: params[:avatar],
                chat_text: params[:chat]}
    Pusher.trigger(params[:channel], 'chat_message', data)
  end
  def show_team_clue
    data = {cell_num: params[:cell_num],
                across: params[:across],
                red: params[:red],
                green: params[:green],
                blue: params[:blue],
                solver_id: params[:solver_id]
                }
    Pusher.trigger(params[:channel], 'outline_team_clue', data)
    render nothing: true
  end
end