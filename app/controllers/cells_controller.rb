class CellsController < ApplicationController
  
  #PATCH/PUT /cells/:id or cell_path
  def update
    @cell = Cell.find(params[:id])
    @cell.update_attributes(params[:cell])
    render nothing: true
  end

  #PUT /cells/:id/toggle_void or toggle_void_cell_path
  def toggle_void
    @cell = Cell.find(params[:id])
    @cell.toggle_void
    @mirror_cell = @cell.get_mirror_cell

    render nothing: true
  end

end