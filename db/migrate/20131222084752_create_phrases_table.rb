class CreatePhrasesTable < ActiveRecord::Migration
  def change
    create_table :phrases do |t|
      t.text :content, null: false
      t.timestamps
    end

    change_table :clues do |t|
      t.belongs_to :phrase
    end
  end
end
