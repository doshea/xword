class CommentContentFromTextToString < ActiveRecord::Migration
  def self.up
    change_column :comments, :content, :string
  end
  def self.down
    change_column :comments, :content, :text
  end
end
