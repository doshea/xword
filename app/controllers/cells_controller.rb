class CellsController < ApplicationController
  def index
    @cells = Cell.all
  end
  def toggle_void
    @cell = Cell.find(params[:id])
    @cell.is_void = !@cell.is_void?
    @cell.save
    @mirror_cell = @cell.ensure_mirrored
    @cell.crossword.number_cells
    puts 'hello'
  end
end