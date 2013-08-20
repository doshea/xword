class CreateCellsTable < ActiveRecord::Migration
  def change
    create_table :cells do |t|
      t.string :letter

      t.integer :row, null: false
      t.integer :col, null: false
      t.integer :index, null:false
      t.integer :cell_num

      t.boolean :is_void, null: false, default: false
      t.boolean :is_across_start, default: false
      t.boolean :is_down_start, default: false

      t.belongs_to :crossword
      t.belongs_to :across_clue
      t.belongs_to :down_clue
      t.belongs_to :left_cell
      t.belongs_to :above_cell

      t.timestamps
    end
  end
end