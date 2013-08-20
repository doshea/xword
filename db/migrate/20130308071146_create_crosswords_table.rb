class CreateCrosswordsTable < ActiveRecord::Migration
  def change
    create_table :crosswords do |t|
      t.string :title, null: false, default: 'Untitled'
      t.text :letters, default: '', null: false
      t.text :description

      t.integer :rows, null: false, default: 15
      t.integer :cols, null: false, default: 15

      t.boolean :published, default: false
      t.datetime :date_published

      t.belongs_to :user

      t.timestamps
    end
  end
end
