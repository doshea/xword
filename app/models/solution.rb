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
#  team         :boolean          default(FALSE), not null
#  key          :string(255)
#

class Solution < ActiveRecord::Base
  attr_accessible :letters, :is_complete, :user_id, :crossword_id

  belongs_to :user, inverse_of: :solutions
  belongs_to :crossword, inverse_of: :solutions

  has_many :solution_partnerings, inverse_of: :solution
  has_many :teammates, through: :solution_partnerings, source: :user

  scope :completed, -> { where(is_complete: true)}

  before_save :check_completion

  def check_completion
    self.is_complete = (self.letters == self.crossword.letters)
    true
  end

  def self.generate_unique_key
    valid = false
    while !valid do
      new_key = (0..5).map{(65+rand(26) + rand(2)*32).chr}.join
      valid = Solution.where(key: new_key).empty?
    end
    new_key
  end

  def percent_complete
    letter_count = self.letters.length
    valid_letter_count = self.letters.gsub(/( |_)/, '').length
    percent = ((valid_letter_count.to_f)/(letter_count)*100).round(1)
    {numerator: valid_letter_count, denominator: letter_count, percent: percent}
  end

  def percent_correct
    current_letters = self.letters
    cw_letters = self.crossword.letters
    sum = 0
    current_letters.split(//).each_with_index do |char, index|
      sum += 1 if (cw_letters[index] == char) and (char != '_')
    end
    ((sum.to_f/current_letters.length)*100).round(2)
  end

  scope :complete, -> {where(solution_complete: true)}
  scope :incomplete, -> {where(solution_complete: false)}
  scope :order_recent, -> {order(updated_at: :desc)}
end
