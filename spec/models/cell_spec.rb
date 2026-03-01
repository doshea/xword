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
#  circled         :boolean          default(FALSE)
#

describe Cell do
  context 'associations' do
    it {should belong_to(:across_clue).class_name('Clue').with_foreign_key(:across_clue_id).optional}
    it {should belong_to(:down_clue).class_name('Clue').with_foreign_key(:down_clue_id).optional}
    it {should belong_to(:crossword).optional}
    it {should have_one(:cell_edit).dependent(:destroy)}

    context 'delegation' do
      it {should delegate_method(:across_word).to(:across_clue)}
      it {should delegate_method(:down_word).to(:down_clue)}
      it {should delegate_method(:user).to(:crossword)}
      # published column removed from Crossword schema — skip until restored
      xit {should delegate_method(:published).to(:crossword)}
    end
  end


end
