class RemoveDefaultImageFromUsersTable < ActiveRecord::Migration
  def up
    change_column :users, :image, :text, :default => nil
  end

  def down
    change_column :users, :image, :text, :default => "https://s3.amazonaws.com/crossword-cafe/default_user_img.jpg"
  end
end
