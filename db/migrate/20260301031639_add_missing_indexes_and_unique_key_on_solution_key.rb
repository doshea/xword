class AddMissingIndexesAndUniqueKeyOnSolutionKey < ActiveRecord::Migration[8.1]
  def change
    # Unique partial index — only non-NULL keys need to be unique.
    # WHERE clause excludes solo solutions (key IS NULL) so they don't conflict.
    add_index :solutions, :key, unique: true, where: "key IS NOT NULL",
              name: "index_solutions_on_key_unique"

    # FK indexes missing from the original 2013-2017 schema.
    # Without these every FK lookup is a full table scan.
    add_index :cells,                :crossword_id
    add_index :cells,                :across_clue_id
    add_index :cells,                :down_clue_id

    add_index :clues,                :word_id
    add_index :clues,                :phrase_id
    add_index :clues,                :user_id

    add_index :cell_edits,           :cell_id

    add_index :comments,             :user_id
    add_index :comments,             :crossword_id
    add_index :comments,             :base_comment_id

    add_index :crosswords,           :user_id

    add_index :favorite_puzzles,     :crossword_id
    add_index :favorite_puzzles,     :user_id

    add_index :solution_partnerings, :user_id
    add_index :solution_partnerings, :solution_id

    add_index :solutions,            :user_id
    add_index :solutions,            :crossword_id

    # auth_token is looked up on every request in ApplicationController#authenticate.
    add_index :users,                :auth_token, unique: true

    add_index :unpublished_crosswords, :user_id
  end
end
