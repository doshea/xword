class AddCrosswordsTable < ActiveRecord::Migration
  def change
    create_table :crosswords do |t|
      t.string :title, :null => false, :default => 'Untitled'
      t.boolean :published, :default => false
      t.datetime :date_published
      t.text :description
      t.integer :rows, :null => false, :default => 15
      t.integer :cols, :null => false, :default => 15
      t.text :letters
      t.text :gridnums
      t.text :circles
      t.belongs_to :user
      t.timestamps
    end
  end
end
