# == Schema Information
#
# Table name: cells
#
#  id              :integer          not null, primary key
#  row             :integer          not null
#  col             :integer          not null
#  index           :integer          not null
#  cell_num        :integer
#  is_void         :boolean          default(FALSE), not null
#  is_across_start :boolean          default(FALSE)
#  is_down_start   :boolean          default(FALSE)
#  crossword_id    :integer
#  across_clue_id  :integer
#  down_clue_id    :integer
#  left_cell_id    :integer
#  above_cell_id   :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  letter          :string(255)
#

require 'spec_methods'

FactoryGirl.define do
  factory :cell, class: Cell  do
    row {rand(30) + 1}
    col {rand(30) + 1}
    index {(row - 1) * 30 + col - 1}
    is_void false

    factory :void_cell do
      is_void true
      letter nil
    end


  end
end