class AddPreviewToCrosswords < ActiveRecord::Migration
  def change
    add_column :crosswords, :preview, :text
  end
end