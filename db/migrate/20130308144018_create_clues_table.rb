class CreateCluesTable < ActiveRecord::Migration
  def change
    create_table :clues do |t|
      t.text :content, default: 'ENTER CLUE'
      t.integer :difficulty, default: 1
      t.belongs_to :user
      t.belongs_to :word
      t.timestamps
    end
  end
end
