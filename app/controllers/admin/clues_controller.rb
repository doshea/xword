class Admin::CluesController < ApplicationController
  before_action :ensure_admin
  before_action :find_object, only: [:edit, :update, :destroy]

  #GET /admin/clues or admin_clues_path
  def index
    cw_ids = Crossword.pluck(:id)
    across_query = Clue.joins(:across_cells).where(cells: {crossword_id: cw_ids, is_across_start: true}).to_sql
    down_query = Clue.joins(:down_cells).where(cells: {crossword_id: cw_ids, is_down_start: true}).to_sql
    @clues = Clue.paginate_by_sql("(#{across_query}) UNION DISTINCT (#{down_query}) ORDER BY \"id\" ASC", page: params[:page])
  end

  #GET /admin/clues/:id/edit or edit_admin_clue_path
  def edit
  end

  #PATCH/PUT /admin/clues/:id or admin_clue_path
  # Replaced: alert_js (jquery_ujs JS response) → redirect (Turbo follows redirect) #
  def update
    if @clue.update(update_clue_params)
      redirect_to admin_clues_path, notice: 'Clue updated.'
    else
      redirect_to edit_admin_clue_path(@clue), alert: 'Error updating clue.'
    end
  end

  #DELETE /admin/clues/:id or admin_clue_path
  # Replaced: alert_js + destroy.js.erb DOM removal → redirect to index (Turbo follows) #
  def destroy
    if @clue.destroy
      redirect_to admin_clues_path, notice: 'Clue deleted.'
    else
      redirect_to admin_clues_path, alert: 'Error deleting clue.'
    end
  end

  private
  def update_clue_params
    params.require(:clue).permit(:content, :difficulty)
  end
end