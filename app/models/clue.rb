# == Schema Information
#
# Table name: clues
#
#  id         :integer          not null, primary key
#  content    :text             default("ENTER CLUE")
#  difficulty :integer          default(1)
#  user_id    :integer
#  word_id    :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Clue < ActiveRecord::Base
  attr_accessible :content, :difficulty, :user_id, :word_id, :crossword_ids
  before_save :strip_tags

  has_many :across_cells, class_name: 'Cell', foreign_key: 'across_clue_id', inverse_of: :across_clue, dependent: :nullify
  has_many :down_cells, class_name: 'Cell', foreign_key: 'down_clue_id', inverse_of: :down_clue, dependent: :nullify

  belongs_to :word, inverse_of: :clues
  belongs_to :user, inverse_of: :clues
  has_many :crosswords, through: :across_cells, inverse_of: :across_clues
  has_many :crosswords, through: :down_cells, inverse_of: :down_clues

  validates :content, presence: true, length: {maximum: 100}
  validates :difficulty, numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 5}

  private
  def strip_tags
    self.content = ActionController::Base.helpers.strip_tags(self.content)
  end
end
