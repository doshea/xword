# == Schema Information
#
# Table name: cell_edits
#
#  id                  :integer          not null, primary key
#  across_clue_content :text
#  down_clue_content   :text
#  cell_id             :integer
#  created_at          :datetime
#  updated_at          :datetime
#

class CellEdit < ApplicationRecord
  belongs_to :cell, inverse_of: :cell_edit, optional: true

end