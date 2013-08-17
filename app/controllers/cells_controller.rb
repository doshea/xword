class CellsController < ApplicationController
  def index
    @cells = Cell.all
  end
  def toggle_void
    @cell = Cell.find(params[:id])
    @cell.toggle_void
    @mirror_cell = @cell.get_mirror_cell

    render nothing: true
  end
end