class Admin::CluesController < ApplicationController
  before_filter :ensure_admin

  def index
    published_cw_ids = Crossword.published.pluck(:id)
    across_query = Clue.joins(:across_cells).where(cells: {crossword_id: published_cw_ids, is_across_start: true}).to_sql
    down_query = Clue.joins(:down_cells).where(cells: {crossword_id: published_cw_ids, is_down_start: true}).to_sql
    @clues = Clue.paginate_by_sql("(#{across_query}) UNION DISTINCT (#{down_query}) ORDER BY \"id\" ASC", page: params[:page])
  end

  def edit
    @clue = Clue.find(params[:id])
  end

  def update
    @clue = Clue.find(params[:id])
    @clue.update_attributes(params[:clue])
  end

  def destroy
    @clue = Clue.find(params[:id])
    @clue.destroy
  end

end