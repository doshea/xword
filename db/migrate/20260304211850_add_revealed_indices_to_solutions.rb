class AddRevealedIndicesToSolutions < ActiveRecord::Migration[8.1]
  def change
    add_column :solutions, :revealed_indices, :text, default: '[]', null: false
  end
end
