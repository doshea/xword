class AddWordsTable < ActiveRecord::Migration
  def change
    create_table :words do |t|
      t.string :content
      t.timestamps
    end
  end
end
