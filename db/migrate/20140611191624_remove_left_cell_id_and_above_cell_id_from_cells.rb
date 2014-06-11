class RemoveLeftCellIdAndAboveCellIdFromCells < ActiveRecord::Migration
  def change
    remove_column :cells, :left_cell_id, :integer
    remove_column :cells, :above_cell_id, :integer
  end
end
