RSpec.describe CrosswordPublisher do
  let(:user) { create(:user) }
  let(:ucw) { create(:unpublished_crossword, user: user, rows: 5, cols: 5) }

  before do
    # Fill letters: 25 non-void cells with letters
    ucw.update!(
      letters: %w[A M I G O V O L O W A N I O N I D O S E L O N E R],
      across_clues: ['A friend'] + [nil] * 24,
      down_clues: ['Benefit'] + [nil] * 24
    )
  end

  describe '.publish' do
    it 'creates a crossword with correct attributes' do
      expect { CrosswordPublisher.publish(ucw) }.to change(Crossword, :count).by(1)
      crossword = Crossword.order(:created_at).last
      expect(crossword.title).to eq ucw.title
      expect(crossword.rows).to eq 5
      expect(crossword.cols).to eq 5
      expect(crossword.user).to eq user
    end

    it 'destroys the unpublished crossword' do
      expect { CrosswordPublisher.publish(ucw) }.to change(UnpublishedCrossword, :count).by(-1)
    end

    it 'returns the new crossword' do
      result = CrosswordPublisher.publish(ucw)
      expect(result).to be_a(Crossword)
      expect(result).to be_persisted
    end

    it 'raises BlankCellsError when cells are blank' do
      ucw.update!(letters: [''] * 25)
      expect { CrosswordPublisher.publish(ucw) }.to raise_error(
        CrosswordPublisher::BlankCellsError, /25 cells still blank/
      )
    end

    it 'does not create a crossword when blank cells error is raised' do
      ucw.update!(letters: [''] * 25)
      expect {
        CrosswordPublisher.publish(ucw) rescue nil
      }.not_to change(Crossword, :count)
    end

    it 'rolls back on unexpected failure' do
      allow_any_instance_of(Crossword).to receive(:number_cells).and_raise(StandardError, 'unexpected')
      expect {
        CrosswordPublisher.publish(ucw) rescue nil
      }.not_to change(Crossword, :count)
    end
  end
end
