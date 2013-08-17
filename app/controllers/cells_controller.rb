class CellsController < ApplicationController
  def index
    @cells = Cell.all
  end
  def update
    @cell = Cell.find(params[:id])
    @cell.update_attributes(params[:cell])
    render nothing: true
  end
  def toggle_void
    @cell = Cell.find(params[:id])
    @cell.toggle_void
    @mirror_cell = @cell.get_mirror_cell

    render nothing: true
  end
end