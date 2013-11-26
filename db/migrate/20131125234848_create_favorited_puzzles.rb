class CreateFavoritedPuzzles < ActiveRecord::Migration
  def change
    create_table :favorite_puzzles do |t|
      t.belongs_to :crossword
      t.belongs_to :user

      t.timestamps
    end
  end
end