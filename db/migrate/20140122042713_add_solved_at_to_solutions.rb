class AddSolvedAtToSolutions < ActiveRecord::Migration
  def change
    add_column :solutions, :solved_at, :datetime, default: nil
  end
end