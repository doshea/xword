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
#  created_at      :datetime
#  updated_at      :datetime
#  circled         :boolean          default(FALSE)
#

describe Cell do
  context 'associations' do
    it {should belong_to(:across_clue).class_name('Clue').with_foreign_key(:across_clue_id)}
    it {should belong_to(:down_clue).class_name('Clue').with_foreign_key(:down_clue_id)}
    it {should belong_to :crossword}
    it {should have_one(:right_cell).class_name('Cell').with_foreign_key('left_cell_id')}
    it {should have_one(:below_cell).class_name('Cell').with_foreign_key('above_cell_id')}
    it {should belong_to(:left_cell).class_name('Cell').with_foreign_key('left_cell_id')}
    it {should belong_to(:above_cell).class_name('Cell').with_foreign_key('above_cell_id')}
    it {should have_one(:cell_edit).dependent(:destroy)}

    context 'delegation' do
      it {should delegate_method(:across_word).to(:across_clue)}
      it {should delegate_method(:down_word).to(:down_clue)}
      it {should delegate_method(:user).to(:crossword)}
    end
  end


end
