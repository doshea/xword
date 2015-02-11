class CreateUnpublishedCrosswords < ActiveRecord::Migration
  def change
    create_table :unpublished_crosswords do |t|
      t.string :title, null: false, default: 'Untitled'
      t.text :letters, array: true, default: []
      t.text :description

      t.integer :rows
      t.integer :cols

      t.belongs_to :user
      t.text :circles, array: true, default: []
      t.text :potential_words, array: true, default: []

      t.timestamps
    end
  end
  def up
    drop_table :potential_crosswords_potential_words
  end
  def down
    create_table :potential_crosswords_potential_words, id: false do |t|
      t.belongs_to :crossword
      t.belongs_to :word
    end
  end
end