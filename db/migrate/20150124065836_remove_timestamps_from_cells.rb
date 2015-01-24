class RemoveTimestampsFromCells < ActiveRecord::Migration
  def change
    remove_column :cells, :created_at, :datetime
    remove_column :cells, :updated_at, :datetime
    remove_column :clues, :created_at, :datetime
    remove_column :clues, :updated_at, :datetime
  end
end
