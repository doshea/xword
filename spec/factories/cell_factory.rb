# == Schema Information
#
# Table name: cells
#
#  id              :integer          not null, primary key
#  letter          :string(255)
#  row             :integer          not null
#  col             :integer          not null
#  index           :integer          not null
#  cell_num        :integer
#  is_void         :boolean          default(FALSE), not null
#  is_across_start :boolean          default(FALSE), not null
#  is_down_start   :boolean          default(FALSE), not null
#  crossword_id    :integer
#  across_clue_id  :integer
#  down_clue_id    :integer
#  left_cell_id    :integer
#  above_cell_id   :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

require 'spec_methods'

FactoryGirl.define do
  factory :cell  do
    row {rand(30) + 1}
    col {rand(30) + 1}
    index {(row - 1) * 30 + col - 1}

    factory :void_cell do
      is_void true
      letter nil
    end

    factory :nonvoid_cell do
      letter {random_char}
      is_void false

      factory :random_nonvoid_cell do
        is_across_start {[true, false].sample}
        is_down_start {[true, false].sample}
      end

      factory :across_start_cell do
        is_across_start true
        cell_num {rand(150)+1}
      end

      factory :down_start_cell do
        is_down_start true
        cell_num {rand(150)+1}
      end

      factory :both_start_cell do
        is_across_start true
        is_down_start true
        cell_num {rand(150)+1}
      end
    end

  end
end
