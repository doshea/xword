class MakeSolutionPartneringIdsNonNull < ActiveRecord::Migration
  def change
    change_column(:solution_partnerings, :user_id, :integer, null: false)
    change_column(:solution_partnerings, :solution_id, :integer, null: false)
  end
end
