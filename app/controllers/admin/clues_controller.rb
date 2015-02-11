class Admin::CluesController < ApplicationController
  before_action :ensure_admin
  before_action :find_object, only: [:edit, :update, :destroy]

  #GET /admin/clues or admin_clues_path
  def index
    published_cw_ids = Crossword.published.pluck(:id)
    across_query = Clue.joins(:across_cells).where(cells: {crossword_id: published_cw_ids, is_across_start: true}).to_sql
    down_query = Clue.joins(:down_cells).where(cells: {crossword_id: published_cw_ids, is_down_start: true}).to_sql
    @clues = Clue.paginate_by_sql("(#{across_query}) UNION DISTINCT (#{down_query}) ORDER BY \"id\" ASC", page: params[:page])
  end

  #GET /admin/clues/:id/edit or edit_admin_clue_path
  def edit
  end

  #PATCH/PUT /admin/clues/:id or admin_clue_path
  # AJAX #
  def update
    if @clue.update_attributes(update_clue_params)
      alert_js('SUCCESS clue updated.')
    else
      alert_js('!!!ERROR updating clue!!!')
    end
  end

  #DELETE /admin/clues/:id or admin_clue_path
  # AJAX #
  def destroy
    if @clue.destroy
      alert_js('SUCCESS clue deleted.')
    else
      alert_js('!!!ERROR deleting clue!!!')
    end
  end

  private
  def update_clue_params
    params.require(:clue).permit(:content, :difficulty)
  end
end