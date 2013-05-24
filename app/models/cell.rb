# == Schema Information
#
# Table name: cells
#
#  id             :integer          not null, primary key
#  row            :integer          not null
#  col            :integer          not null
#  index          :integer          not null
#  is_void        :boolean          default(FALSE), not null
#  across_clue_id :integer
#  down_clue_id   :integer
#  crossword_id   :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

class Cell < ActiveRecord::Base
  attr_accessible :row, :col, :index, :is_void, :across_clue_id, :down_clue_id, :crossword_id

  belongs_to :across_clue, polymorphic: true, inverse_of: :cells
  belongs_to :down_clue, polymorphic: true, inverse_of: :cells

  belongs_to :crossword, inverse_of: :cells
  delegate :word, to: :clue, allow_nil: true
  delegate :user, to: :crossword, allow_nil: true

end
