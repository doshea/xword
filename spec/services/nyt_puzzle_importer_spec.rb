RSpec.describe NytPuzzleImporter do
  describe '.import' do
    let!(:nytimes_user) { create(:user, username: 'nytimes') }

    # generate_preview uses ImageMagick + CarrierWave; stub it in unit tests
    before { allow_any_instance_of(Crossword).to receive(:generate_preview) }

    let(:puzzle_hash) do
      {
        'title' => 'NY Times, Mon, Jan 01, 2024',
        'size' => { 'rows' => 5, 'cols' => 5 },
        'grid' => %w[A M I G O V O L O W A N I O N I D O S E L O N E R],
        'clues' => {
          'across' => [
            '1. A male friend',
            '6. To baptize',
            '7. A negative ion',
            '8. A sugar',
            '9. A solitary person'
          ],
          'down' => [
            '1. Benefit',
            '2. Extreme',
            '3. Ancient Troy',
            '4. A water fowl',
            '5. A possesser'
          ]
        }
      }
    end

    it 'creates a crossword with correct attributes' do
      expect { NytPuzzleImporter.import(puzzle_hash) }.to change(Crossword, :count).by(1)
      crossword = Crossword.unscoped.last
      expect(crossword.rows).to eq 5
      expect(crossword.cols).to eq 5
      expect(crossword.letters).to eq 'AMIGOVOLOWANIONIDOSELONER'
    end

    it 'assigns the crossword to the nytimes user' do
      NytPuzzleImporter.import(puzzle_hash)
      expect(nytimes_user.crosswords.count).to eq 1
    end

    it 'skips duplicate puzzles' do
      NytPuzzleImporter.import(puzzle_hash)
      expect(NytPuzzleImporter.import(puzzle_hash)).to be_nil
    end

    it 'raises if the nytimes user does not exist' do
      nytimes_user.destroy
      expect { NytPuzzleImporter.import(puzzle_hash) }.to raise_error(RuntimeError, /nytimes/)
    end

    it 'handles rebus entries by replacing with hyphens' do
      puzzle_hash['grid'][0] = 'AB'
      NytPuzzleImporter.import(puzzle_hash)
      crossword = Crossword.unscoped.last
      expect(crossword.letters[0]).to eq '-'
    end

    it 'applies circles when present' do
      circles = [1] + [0] * 24
      puzzle_hash['circles'] = circles
      NytPuzzleImporter.import(puzzle_hash)
      crossword = Crossword.unscoped.last
      expect(crossword.circled).to be true
    end

    it 'rolls back on failure, leaving no orphaned crossword' do
      allow_any_instance_of(Crossword).to receive(:set_clue).and_raise(StandardError, 'clue assignment failed')
      expect {
        NytPuzzleImporter.import(puzzle_hash) rescue nil
      }.not_to change(Crossword, :count)
    end
  end
end
