class FriendRequest < ActiveRecord::Base
  belongs_to :sender
  belongs_to :recipient
end