class CreateFriendshipsAndFriendRequests < ActiveRecord::Migration[5.0]
  def change
    create_table :friend_requests, id: false, force: true do |t|
      t.belongs_to :sender, index: true
      t.belongs_to :recipient, index: true
      t.string :accompany_message
      t.timestamps
    end

    create_table :friendships, id: false, force: true do |t|
      t.belongs_to :user, index: true
      t.belongs_to :friend, index: true
    end
  end
end