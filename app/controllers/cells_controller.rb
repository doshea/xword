class CellsController < ApplicationController
  before_action :find_object

  #PATCH/PUT /cells/:id or cell_path
  def update
    @cell.update(cell_params)
    head :ok
  end

  #PUT /cells/:id/toggle_void or toggle_void_cell_path
  def toggle_void
    @cell.toggle_void
    @mirror_cell = @cell.get_mirror_cell
    head :ok
  end

  private
  def cell_params
    params.require(:cell).permit(:letter)
  end

end