class AddLetterToCells < ActiveRecord::Migration
  def change
    add_column :cells, :letter, :string
  end
end