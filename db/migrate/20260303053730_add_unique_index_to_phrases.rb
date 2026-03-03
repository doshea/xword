class AddUniqueIndexToPhrases < ActiveRecord::Migration[8.1]
  def change
    add_index :phrases, 'LOWER(content)', unique: true, name: 'index_phrases_on_lower_content'
  end
end
