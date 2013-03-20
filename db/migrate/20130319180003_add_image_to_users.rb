class AddImageToUsers < ActiveRecord::Migration
  def change
    add_column :users, :image, :text, :default => 'https://s3.amazonaws.com/crossword-cafe/default_user_img.jpg'
  end
end
