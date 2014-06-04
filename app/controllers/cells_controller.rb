class CellsController < ApplicationController
  before_action :find_cell

  #PATCH/PUT /cells/:id or cell_path
  def update
    @cell.update_attributes(cell_params)
    render nothing: true
  end

  #PUT /cells/:id/toggle_void or toggle_void_cell_path
  def toggle_void
    @cell.toggle_void
    @mirror_cell = @cell.get_mirror_cell
    render nothing: true
  end

  private
  def find_cell
    @cell = Cell.find(params[:id])
  end

  def cell_params
    params.require(:cell).permit(:letter)
  end

end