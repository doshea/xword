class AddCluesToUnpublishedCrosswords < ActiveRecord::Migration
  def change
    add_column :unpublished_crosswords, :across_clues, :text, array: true, default: []
    add_column :unpublished_crosswords, :down_clues, :text, array: true, default: []
  end
end