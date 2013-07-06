class CellsController < ApplicationController
  def index
    @cells = Cell.all
  end
  def toggle_void
    @cell = Cell.find(params[:id])
    @mirror_cell = @cell.toggle_void
  end
end