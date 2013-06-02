class CreateSolutionsTable < ActiveRecord::Migration
  def change
    create_table :solutions do |t|
      t.text :letters, default: '', null: false
      t.boolean :is_complete, default: false, null: false
      t.belongs_to :user
      t.belongs_to :crossword
      t.timestamps
    end
  end
end
