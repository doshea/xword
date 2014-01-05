class ClueContentFromTextToString < ActiveRecord::Migration
  def self.up
    change_column :clues, :content, :string, default: 'ENTER CLUE'
  end
  def self.down
    change_column :clues, :content, :text, default: 'ENTER CLUE'
  end
end