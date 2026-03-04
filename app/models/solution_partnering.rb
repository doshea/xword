# == Schema Information
#
# Table name: solution_partnerings
#
#  id          :integer          not null, primary key
#  user_id     :integer          not null
#  solution_id :integer          not null
#  created_at  :datetime
#  updated_at  :datetime
#

class SolutionPartnering < ApplicationRecord

  belongs_to :user, inverse_of: :solution_partnerings
  belongs_to :solution, inverse_of: :solution_partnerings
  has_one :crossword, through: :solution, inverse_of: :solution_partnerings
end
