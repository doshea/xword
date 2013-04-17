# == Schema Information
#
# Table name: solutions
#
#  id           :integer          not null, primary key
#  letters      :text             default(""), not null
#  is_complete  :boolean          default(FALSE), not null
#  user_id      :integer
#  crossword_id :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class Solution < ActiveRecord::Base
  attr_accessible :letters, :is_complete, :user_id, :crossword_id

  belongs_to :user, :inverse_of => :solutions
  belongs_to :crossword, :inverse_of => :solutions

  before_save :check_completion

  def check_completion
    self.is_complete = (self.letters == self.crossword.letters)
    true
  end

  scope :complete, where(:solution_complete => true)
  scope :incomplete, where(:solution_complete => false)
  scope :order_recent, order('updated_at DESC')
end
