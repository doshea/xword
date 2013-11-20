class SolutionsController < ApplicationController
  def index
  end
  def update
    solution = Solution.find(params[:id])
    solution.letters = params[:letters]
    solution.save
  end
  def get_incorrect
    @mismatches = Solution.find(params[:id]).crossword.return_mismatches(params[:letters])
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