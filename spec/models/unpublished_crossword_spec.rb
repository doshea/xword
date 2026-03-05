RSpec.describe UnpublishedCrossword, type: :model do
  let(:user) { create(:user) }

  # -------------------------------------------------------------------------
  # Crosswordable validations
  # -------------------------------------------------------------------------
  describe 'validations' do
    it 'is valid with valid attributes' do
      ucw = build(:unpublished_crossword, user: user)
      expect(ucw).to be_valid
    end

    it 'is invalid with rows below minimum' do
      ucw = build(:unpublished_crossword, user: user, rows: 3)
      expect(ucw).not_to be_valid
      expect(ucw.errors[:rows]).to be_present
    end

    it 'is invalid with rows above maximum' do
      ucw = build(:unpublished_crossword, user: user, rows: 31)
      expect(ucw).not_to be_valid
    end

    it 'is invalid with cols below minimum' do
      ucw = build(:unpublished_crossword, user: user, cols: 3)
      expect(ucw).not_to be_valid
    end

    it 'is invalid with cols above maximum' do
      ucw = build(:unpublished_crossword, user: user, cols: 31)
      expect(ucw).not_to be_valid
    end

    it 'is invalid with title shorter than minimum' do
      ucw = build(:unpublished_crossword, user: user, title: 'AB')
      expect(ucw).not_to be_valid
      expect(ucw.errors[:title]).to be_present
    end

    it 'is invalid with title longer than maximum' do
      ucw = build(:unpublished_crossword, user: user, title: 'A' * 36)
      expect(ucw).not_to be_valid
    end
  end

  # -------------------------------------------------------------------------
  # before_create :populate_arrays
  # -------------------------------------------------------------------------
  describe 'populate_arrays callback' do
    it 'sets letters to an array of empty strings on create' do
      ucw = create(:unpublished_crossword, user: user, rows: 4, cols: 4)
      expect(ucw.letters).to eq([''] * 16)
    end

    it 'sets circles to a string of spaces on create' do
      ucw = create(:unpublished_crossword, user: user, rows: 4, cols: 4)
      expect(ucw.circles).to eq(' ' * 16)
    end

    it 'sets across_clues to an array of nils on create' do
      ucw = create(:unpublished_crossword, user: user, rows: 4, cols: 4)
      expect(ucw.across_clues).to eq([nil] * 16)
    end

    it 'sets down_clues to an array of nils on create' do
      ucw = create(:unpublished_crossword, user: user, rows: 4, cols: 4)
      expect(ucw.down_clues).to eq([nil] * 16)
    end

    it 'sizes arrays to rows * cols' do
      ucw = create(:unpublished_crossword, user: user, rows: 5, cols: 6)
      expect(ucw.letters.size).to eq 30
      expect(ucw.circles.length).to eq 30
    end
  end

  # -------------------------------------------------------------------------
  # #add_potential_word
  # -------------------------------------------------------------------------
  describe '#add_potential_word' do
    let(:ucw) { create(:unpublished_crossword, user: user) }

    it 'adds a word and saves' do
      expect(ucw.add_potential_word('HELLO')).to be_truthy
      ucw.reload
      expect(ucw.potential_words).to include('HELLO')
    end

    it 'returns false when word already exists' do
      ucw.add_potential_word('HELLO')
      expect(ucw.add_potential_word('HELLO')).to eq false
    end

    it 'sorts words by length descending' do
      ucw.add_potential_word('HI')
      ucw.add_potential_word('HELLO')
      ucw.add_potential_word('CROSSWORD')
      ucw.reload
      expect(ucw.potential_words).to eq %w[CROSSWORD HELLO HI]
    end
  end

  # -------------------------------------------------------------------------
  # #remove_potential_word
  # -------------------------------------------------------------------------
  describe '#remove_potential_word' do
    let(:ucw) { create(:unpublished_crossword, :with_words, user: user) }

    it 'removes the word and saves' do
      ucw.remove_potential_word('HELLO')
      ucw.reload
      expect(ucw.potential_words).not_to include('HELLO')
    end

    it 'handles removing a word that is not in the list' do
      expect { ucw.remove_potential_word('MISSING') }.not_to raise_error
      ucw.reload
      expect(ucw.potential_words).to eq %w[HELLO WORLD]
    end
  end

  # -------------------------------------------------------------------------
  # #letters_to_clue_numbers
  # -------------------------------------------------------------------------
  describe '#letters_to_clue_numbers' do
    it 'returns across and down hashes' do
      ucw = create(:unpublished_crossword, user: user, rows: 4, cols: 4)
      result = ucw.letters_to_clue_numbers
      expect(result).to have_key(:across)
      expect(result).to have_key(:down)
    end

    it 'assigns clue numbers correctly for a simple grid with no voids' do
      # 4x4 grid, no voids — all cells are letters (empty strings from factory)
      # Expected numbering (standard crossword rules):
      #   [1] [2] [3] [4]     Top row: each cell starts a down clue; col 0 also starts across
      #   [5] [ ] [ ] [ ]     Row 1: col 0 starts across; rest continue down clues
      #   [6] [ ] [ ] [ ]     Row 2: col 0 starts across
      #   [7] [ ] [ ] [ ]     Row 3: col 0 starts across
      ucw = create(:unpublished_crossword, user: user, rows: 4, cols: 4)
      result = ucw.letters_to_clue_numbers

      # Top-left gets clue 1 for both across and down
      expect(result[:across][0]).to eq 1
      expect(result[:down][0]).to eq 1

      # Top row, col 1 — continuation of across clue, but starts a new down clue
      expect(result[:across][1]).to be_nil
      expect(result[:down][1]).to eq 2

      # Top row, col 2 — continuation of across, new down
      expect(result[:across][2]).to be_nil
      expect(result[:down][2]).to eq 3

      # Top row, col 3 — continuation of across, new down
      expect(result[:across][3]).to be_nil
      expect(result[:down][3]).to eq 4

      # Row 1, col 0 — new across clue, continuation of down
      expect(result[:across][4]).to eq 5
      expect(result[:down][4]).to be_nil

      # Row 2, col 0 — new across clue, continuation of down
      expect(result[:across][8]).to eq 6
      expect(result[:down][8]).to be_nil

      # Row 3, col 0 — new across clue, continuation of down
      expect(result[:across][12]).to eq 7
      expect(result[:down][12]).to be_nil
    end

    it 'handles voids correctly by starting new clues after voids' do
      # 4x4 grid with a void at position 1 (row 0, col 1)
      ucw = create(:unpublished_crossword, user: user, rows: 4, cols: 4)
      letters = [''] * 16
      letters[1] = nil # void at row 0, col 1
      ucw.update!(letters: letters)

      result = ucw.letters_to_clue_numbers

      # Position 1 is void — should be nil for both
      expect(result[:across][1]).to be_nil
      expect(result[:down][1]).to be_nil

      # Position 2 (row 0, col 2): left neighbor is void → starts new across clue
      expect(result[:across][2]).to be_a(Integer)

      # Position 5 (row 1, col 1): above is void → starts new down clue
      expect(result[:down][5]).to be_a(Integer)
    end
  end
end
