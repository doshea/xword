class CreateCellEditsTable < ActiveRecord::Migration
  def change
    create_table :cell_edits do |t|
      t.text :across_clue_content
      t.text :down_clue_content

      t.belongs_to :cell

      t.timestamps
    end
  end
end
