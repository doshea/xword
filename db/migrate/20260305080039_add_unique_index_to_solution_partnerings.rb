class AddUniqueIndexToSolutionPartnerings < ActiveRecord::Migration[8.1]
  def change
    # Remove the existing non-unique single-column indexes
    remove_index :solution_partnerings, :solution_id
    remove_index :solution_partnerings, :user_id

    # Add a composite unique index (covers both lookup directions)
    add_index :solution_partnerings, [:solution_id, :user_id], unique: true
    add_index :solution_partnerings, :user_id
  end
end
