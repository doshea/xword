# == Schema Information
#
# Table name: solution_partnerings
#
#  id          :integer          not null, primary key
#  user_id     :integer
#  solution_id :integer
#  created_at  :datetime
#  updated_at  :datetime
#

class SolutionPartnering < ActiveRecord::Base
  attr_accessible :user_id, :solution_id

  belongs_to :user
  belongs_to :solution
  has_one :crossword, through: :solution, inverse_of: :solution_partnerings
end
