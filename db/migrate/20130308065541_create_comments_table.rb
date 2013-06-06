class CreateCommentsTable < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.text :content
      t.boolean :flagged, :default => false
      t.belongs_to :user
      t.belongs_to :crossword
      t.belongs_to :base_comment
      t.timestamps
    end
  end
end
