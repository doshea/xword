class DropCrosswordsWordsTable < ActiveRecord::Migration
  def up
    drop_table :crosswords_words
  end
  def down
    create_table :crosswords_words, id: false do |t|
      t.belongs_to :crossword
      t.belongs_to :word
    end
  end
end
