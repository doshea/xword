class FriendRequest < ActiveRecord::Base
  belongs_to :sender, optional: true
  belongs_to :recipient, optional: true
end