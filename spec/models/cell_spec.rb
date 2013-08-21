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

require 'spec_helper'

describe Cell do
  subject(:cell) { create(:random_nonvoid_cell) }

  describe  '#new' do
    it {should be_an_instance_of Cell}
  end

  context 'validations' do

  end

  context 'associations' do
    it { should belong_to(:across_clue) }
    it { should belong_to(:down_clue) }
    it { should belong_to(:crossword) }

    it { should belong_to(:left_cell) }
    it { should belong_to(:above_cell) }

    it { should have_one(:right_cell) }
    it { should have_one(:below_cell) }
  end

end
