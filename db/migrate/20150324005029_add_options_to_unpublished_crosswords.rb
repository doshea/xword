class AddOptionsToUnpublishedCrosswords < ActiveRecord::Migration
  def change
    add_column :unpublished_crosswords, :mirror_voids, :boolean, default: true
    add_column :unpublished_crosswords, :circle_on_click, :boolean, default: false
    add_column :unpublished_crosswords, :one_click_void, :boolean, default: false
    add_column :unpublished_crosswords, :multiletter_cells, :boolean, default: false
  end
  def up
    change_column :unpublished_crosswords, :circles, :text, array: false, default: ''
  end

  def down
    change_column :unpublished_crosswords, :circles, :text, array: true, default: []
  end
end
