# == Schema Information
#
# Table name: clue_instances
#
#  id           :integer          not null, primary key
#  start_cell   :integer
#  is_across    :boolean
#  clue_id      :integer
#  crossword_id :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class ClueInstance < ActiveRecord::Base
  attr_accessible :start_cell, :is_across, :clue_id, :crossword_id, :word_id, :user_id

  belongs_to :clue, inverse_of: :clue_instances
  belongs_to :crossword, inverse_of: :clue_instances
  delegate :word, to: :clue, allow_nil: true
  delegate :user, to: :crossword, allow_nil: true

end