class CreateCellsTable < ActiveRecord::Migration
  def change
    create_table :cells do |t|
      t.integer :row, null: false
      t.integer :col, null: false
      t.integer :index, null:false
      t.boolean :is_void, null: false, default: false
      t.integer :across_clue_id
      t.integer :down_clue_id
      t.integer :crossword_id
      t.timestamps
    end
  end
end