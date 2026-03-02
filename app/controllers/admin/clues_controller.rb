class Admin::CluesController < Admin::BaseController
  def index
    cw_ids = Crossword.pluck(:id)
    across_query = Clue.joins(:across_cells).where(cells: {crossword_id: cw_ids, is_across_start: true}).to_sql
    down_query = Clue.joins(:down_cells).where(cells: {crossword_id: cw_ids, is_down_start: true}).to_sql
    @clues = Clue.paginate_by_sql("(#{across_query}) UNION DISTINCT (#{down_query}) ORDER BY \"id\" ASC", page: params[:page])
  end

  private

  def resource_params
    params.require(:clue).permit(:content, :difficulty)
  end
end
