class AddPerformanceIndexes < ActiveRecord::Migration[8.1]
  def change
    add_index :solutions, [:user_id, :is_complete], name: "index_solutions_on_user_id_and_is_complete"
    add_index :solutions, [:crossword_id, :user_id], name: "index_solutions_on_crossword_id_and_user_id"
    add_index :crosswords, :created_at, name: "index_crosswords_on_created_at"
  end
end
