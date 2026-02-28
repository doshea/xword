class FriendRequest < ApplicationRecord
  belongs_to :sender, optional: true
  belongs_to :recipient, optional: true
end