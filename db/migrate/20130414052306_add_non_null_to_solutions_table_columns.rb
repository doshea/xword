class AddNonNullToSolutionsTableColumns < ActiveRecord::Migration
  def change
    change_column :solutions, :letters, :text, null: false
    change_column :solutions, :is_complete, :boolean, null: false
    change_column :crosswords, :letters, :text, default: '', null: false
    change_column :crosswords, :gridnums, :text, default: '', null: false
    change_column :crosswords, :letters, :text, default: '', null: false
  end
end
