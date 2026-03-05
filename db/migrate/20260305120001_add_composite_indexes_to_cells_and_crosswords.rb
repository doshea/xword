class AddCompositeIndexesToCellsAndCrosswords < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def change
    # Cell navigation (arrow keys) queries by crossword_id + row + col.
    # Supersedes the existing single-column index on crossword_id.
    add_index :cells, [:crossword_id, :row, :col],
              name: :index_cells_on_crossword_row_col,
              algorithm: :concurrently

    # Home page, profile, and NYT pages filter by user_id + sort by created_at DESC.
    # Supersedes the existing single-column index on user_id.
    add_index :crosswords, [:user_id, :created_at],
              name: :index_crosswords_on_user_id_and_created_at,
              order: { created_at: :desc },
              algorithm: :concurrently
  end
end
