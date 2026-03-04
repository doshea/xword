class AddHintsUsedToSolutions < ActiveRecord::Migration[8.1]
  def change
    add_column :solutions, :hints_used, :integer, default: 0, null: false
  end
end
