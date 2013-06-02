class CreateCrosswordsWordsTable < ActiveRecord::Migration
  def change
    create_table :crosswords_words, :id => false do |t|
      t.belongs_to :crossword
      t.belongs_to :word
    end
  end
end