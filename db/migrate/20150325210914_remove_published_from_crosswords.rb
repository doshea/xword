class RemovePublishedFromCrosswords < ActiveRecord::Migration
  def change
    remove_column :crosswords, :published, :boolean
    remove_column :crosswords, :published_at, :datetime
  end
end
