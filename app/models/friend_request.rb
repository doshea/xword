class FriendRequest < ApplicationRecord
  belongs_to :sender, class_name: 'User', optional: true
  belongs_to :recipient, class_name: 'User', optional: true
end
