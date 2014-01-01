class MakeFavoritePuzzleIdsNonNull < ActiveRecord::Migration
  def change
    change_column(:favorite_puzzles, :user_id, :integer, null: false)
    change_column(:favorite_puzzles, :crossword_id, :integer, null: false)
  end
end
