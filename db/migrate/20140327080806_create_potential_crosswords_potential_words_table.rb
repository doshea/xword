class CreatePotentialCrosswordsPotentialWordsTable < ActiveRecord::Migration
  def change
    create_table :potential_crosswords_potential_words, id: false do |t|
      t.belongs_to :crossword
      t.belongs_to :word
    end
  end
end
