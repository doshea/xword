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
  let(:crossword) { create(:crossword, :smaller) }
  let(:cell)      { crossword.cells.reject(&:is_void).first }

  context 'associations' do
    it {should belong_to(:across_clue).class_name('Clue').with_foreign_key(:across_clue_id).optional}
    it {should belong_to(:down_clue).class_name('Clue').with_foreign_key(:down_clue_id).optional}
    it {should belong_to(:crossword).optional}
    it {should have_one(:cell_edit).dependent(:destroy)}

    context 'delegation' do
      it {should delegate_method(:across_word).to(:across_clue)}
      it {should delegate_method(:down_word).to(:down_clue)}
      it {should delegate_method(:user).to(:crossword)}
    end
  end

  describe '#toggle_void' do
    it 'marks a non-void cell as void' do
      expect { cell.toggle_void }.to change { cell.reload.is_void }.from(false).to(true)
    end

    it 'marks a void cell as non-void' do
      cell.update_column(:is_void, true)
      expect { cell.toggle_void }.to change { cell.reload.is_void }.from(true).to(false)
    end
  end

  describe '#get_mirror_cell' do
    it 'returns the symmetric cell on the opposite side of the grid' do
      mirror = cell.get_mirror_cell
      expect(mirror).to be_a(Cell)
      # Mirror of mirror should be the original cell
      expect(mirror.get_mirror_cell).to eq cell
    end
  end

  describe 'navigation helpers' do
    it '#right_cell returns the adjacent cell to the right (or nil at edge)' do
      expect(cell.right_cell).to satisfy { |r| r.nil? || r.is_a?(Cell) }
    end

    it '#below_cell returns the adjacent cell below (or nil at edge)' do
      expect(cell.below_cell).to satisfy { |r| r.nil? || r.is_a?(Cell) }
    end
  end
end
