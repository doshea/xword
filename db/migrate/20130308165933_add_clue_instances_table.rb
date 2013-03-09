class AddClueInstancesTable < ActiveRecord::Migration
  def change
    create_table :clue_instances do |t|
      t.integer :start_cell
      t.boolean :is_across
      t.belongs_to :clue
      t.belongs_to :crossword
      t.timestamps
    end
  end
end
