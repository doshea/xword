class AddUniqueIndexToFavoritePuzzles < ActiveRecord::Migration[8.1]
  def change
    # Add composite unique index to prevent duplicate favorites at the DB level.
    # This backs up the model-level uniqueness validation and prevents TOCTOU races.
    add_index :favorite_puzzles, [:user_id, :crossword_id], unique: true,
              name: 'index_favorite_puzzles_on_user_and_crossword'

    # The individual user_id index is now redundant (composite index covers it).
    remove_index :favorite_puzzles, :user_id, name: 'index_favorite_puzzles_on_user_id'
  end
end
