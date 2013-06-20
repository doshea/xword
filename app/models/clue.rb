# == Schema Information
#
# Table name: clues
#
#  id         :integer          not null, primary key
#  content    :text
#  difficulty :integer
#  user_id    :integer
#  word_id    :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Clue < ActiveRecord::Base
  attr_accessible :content, :difficulty, :user_id, :word_id, :clue_instance_ids, :crossword_ids
  before_save :strip_tags

  has_many :clue_instances, inverse_of: :clue
  belongs_to :word, inverse_of: :clues
  belongs_to :user, inverse_of: :clues
  has_many :crosswords, through: :clue_instances, inverse_of: :clues

  validates :content, presence: true, length: {maximum: 100}
  validates :difficulty, numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 5}

  private
  def strip_tags
    self.content = ActionController::Base.helpers.strip_tags(self.content)
  end
end