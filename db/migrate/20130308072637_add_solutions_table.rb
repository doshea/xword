class AddSolutionsTable < ActiveRecord::Migration
  def change
    create_table :solutions do |t|
      t.text :letters
      t.boolean :is_complete
      t.belongs_to :user
      t.belongs_to :crossword
      t.timestamps
    end
  end
end
