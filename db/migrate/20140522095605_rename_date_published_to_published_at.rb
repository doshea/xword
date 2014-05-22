class RenameDatePublishedToPublishedAt < ActiveRecord::Migration
  def change
    change_table :crosswords do |t|
      t.rename :date_published, :published_at
    end
  end
end
