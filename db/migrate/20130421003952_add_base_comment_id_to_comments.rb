class AddBaseCommentIdToComments < ActiveRecord::Migration
  def change
    add_column :comments, :base_comment_id, :integer
  end
end
