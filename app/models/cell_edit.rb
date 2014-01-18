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

class CellEdit < ActiveRecord::Base
  attr_accessible :across_clue_content, :down_clue_content, :cell_id

end