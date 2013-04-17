class AddDefaultLettersAndCompletionToSolutionsTable < ActiveRecord::Migration
  def change
    change_column :solutions, :letters, :text, default: ''
    change_column :solutions, :is_complete, :boolean, default: false
  end
end