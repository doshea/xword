# == Schema Information
#
# Table name: comments
#
#  id           :integer          not null, primary key
#  content      :text
#  flagged      :boolean          default(FALSE)
#  user_id      :integer
#  crossword_id :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class Comment < ActiveRecord::Base
  attr_accessible :content, :flagged, :user_id, :crossword_id
  belongs_to :user, :inverse_of => :comments
  belongs_to :crossword, :inverse_of => :comments
end
