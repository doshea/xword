# == Schema Information
#
# Table name: solutions
#
#  id           :integer          not null, primary key
#  letters      :text             default("")
#  is_complete  :boolean          default(FALSE)
#  user_id      :integer
#  crossword_id :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class Solution < ActiveRecord::Base
  attr_accessible :letters, :is_complete, :user_id, :crossword_id

  belongs_to :user, :inverse_of => :solutions
  belongs_to :crossword, :inverse_of => :solutions
end
