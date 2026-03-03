# == Schema Information
#
# Table name: crosswords
#
#  id          :integer          not null, primary key
#  title       :string(255)      default("Untitled"), not null
#  letters     :text             default(""), not null
#  description :text
#  rows        :integer          default(15), not null
#  cols        :integer          default(15), not null
#  user_id     :integer
#  created_at  :datetime
#  updated_at  :datetime
#  circled     :boolean          default(FALSE)
#  preview     :text
#

describe Crossword do
  it 'has a valid factory' do
    expect(create(:crossword)).to be_valid
  end

  describe 'associations' do
    it {should belong_to(:user).optional}
    it {should have_many(:comments).order(created_at: :desc).dependent(:destroy)}
    it {should have_many(:solutions).dependent(:destroy)}
    it {should have_many(:cells).order(:index).dependent(:destroy)}
    it {should have_many(:across_clues).through(:cells)}
    it {should have_many(:down_clues).through(:cells)}
    it {should have_many(:across_words).through(:across_clues).source(:word)}
    it {should have_many(:down_words).through(:down_clues).source(:word)}
    it {should have_many :favorite_puzzles}
    it {should have_many :favoriters}
    it {should have_many(:solution_partnerings).through(:solutions)}
  end

  describe 'validations' do
    it { should validate_presence_of(:rows)}
    it { should validate_numericality_of(:rows).only_integer}
    it { should validate_inclusion_of(:rows).in_range(Crossword::MIN_DIMENSION..Crossword::MAX_DIMENSION)}
    it { should validate_presence_of(:cols)}
    it { should validate_numericality_of(:cols).only_integer}
    it { should validate_inclusion_of(:cols).in_range(Crossword::MIN_DIMENSION..Crossword::MAX_DIMENSION)}
    it { should validate_presence_of(:title)}
    it { should validate_length_of(:title).is_at_least(Crossword::MIN_TITLE_LENGTH).is_at_most(Crossword::MAX_TITLE_LENGTH) }
  end

  describe 'INSTANCE METHODS' do
    context 'no requirements' do
      subject {build(:crossword)}

      it 'returns a random row in range' do
        expect(subject.random_row).to be_in(1..subject.rows)
      end
      it 'returns a random row as Integer' do
        expect(subject.random_row).to be_an Integer
      end
      it 'returns a random col in range' do
        expect(subject.random_col).to be_in(1..subject.cols)
      end
      it 'returns a random col as Integer' do
        expect(subject.random_col).to be_an Integer
      end
      it 'returns a random index in range' do
        expect(subject.random_index).to be_in(1..subject.area)
      end
      it 'returns a random index as Integer' do
        expect(subject.random_index).to be_an Integer
      end

      describe "helpers for index/row/col" do
        it 'interconvert properly' do
          index = subject.random_index
          row = subject.row_from_index(index)
          col = subject.col_from_index(index)
          expect(subject.index_from_rc(row, col)).to eq index
        end
        describe '#index_from_rc' do
          it 'raises error on too-high row' do
            expect{subject.index_from_rc(subject.rows * 2, subject.random_col)}.to raise_error(ArgumentError)
          end
          it 'raises error on too-low row' do
            expect{subject.index_from_rc(subject.rows * -1, subject.random_col)}.to raise_error(ArgumentError)
          end
          it 'raises error on too-high col' do
            expect{subject.index_from_rc(subject.random_row, subject.cols * 2)}.to raise_error(ArgumentError)
          end
          it 'raises error on too-low col' do
            expect{subject.index_from_rc(subject.random_row, subject.cols * -1)}.to raise_error(ArgumentError)
          end
        end
        describe '#row_from_index' do
          it 'raises error on too-high index' do
            expect{subject.row_from_index(subject.rows*subject.cols*2)}.to raise_error(ArgumentError)
          end
          it 'raises error on too-low index' do
            expect{subject.row_from_index(subject.rows*subject.cols*-1)}.to raise_error(ArgumentError)
          end
        end
        describe '#col_from_index' do
          it 'raises error on too-high index' do
            expect{subject.col_from_index(subject.rows*subject.cols*2)}.to raise_error(ArgumentError)
          end
          it 'raises error on too-low index' do
            expect{subject.col_from_index(subject.rows*subject.cols*-1)}.to raise_error(ArgumentError)
          end
        end
      end

    end

    context 'requiring letters' do
      subject {build(:crossword)}
      before {subject.populate_letters}
      after {subject.letters = ''}

      context 'real letters and voids' do
        before {subject.randomize_letters_and_voids}
        it 'has a positive nonvoid letter count' do
          expect(subject.nonvoid_letter_count).to be > 0
        end
        it 'nonvoid letter count equals letters minus voids' do
          expect(subject.nonvoid_letter_count).to eq(subject.letters.length - subject.letters.count(' _'))
        end
        describe '#mismatch_array' do
          before do
            #Finds the first alphabetic character to swap it out
            @letter = subject.letters[subject.letters =~ /[a-zA-Z]/]

            if @letter == 'z'
              swapped_letter = 'A'
            else
              swapped_letter = (@letter.ord + 1).chr
            end
            @similar_letters = subject.letters.gsub(@letter, swapped_letter)
          end
          it 'returns the correct length array' do
            swap_count = subject.letters.count(@letter)
            expect(subject.get_mismatches(@similar_letters).length).to eq swap_count
          end

          it 'returns the correct array' do
            mismatches = (0...subject.area).find_all{|i| subject.letters[i] == @letter }
            expect(subject.get_mismatches(@similar_letters)).to eq mismatches
          end

          it 'returns empty array if the solutions match' do
            expect(subject.get_mismatches(subject.letters)).to eq []
          end

          it 'raise an error when the solution is improperly sized' do
            #either halves or doubles the solution
            bad_letters = rand.round.even? ? subject.letters*2 : subject.letters[subject.letters.length/2,subject.letters.length/2]
            expect{subject.get_mismatches(bad_letters)}.to raise_error(ArgumentError)
          end
        end

      end

      describe '#cell_mismatches' do
        # Use predefined_five_by_five for deterministic letter positions:
        # letters = 'AMIGOVOLOWANIONIDOSELONER' (25 chars, 0-indexed, no voids)
        let(:cw) { create(:predefined_five_by_five) }

        context 'spot-check mode (with indices)' do
          it 'returns false for a correct letter' do
            result = cw.cell_mismatches(['A'], indices: [0])
            expect(result).to eq({ 0 => false })
          end

          it 'returns true for an incorrect letter' do
            result = cw.cell_mismatches(['Z'], indices: [0])
            expect(result).to eq({ 0 => true })
          end

          it 'handles multiple indices with mixed results' do
            # indices 0='A'(correct), 1='M' but send 'Z'(incorrect), 2='I'(correct)
            result = cw.cell_mismatches(['A', 'Z', 'I'], indices: [0, 1, 2])
            expect(result).to eq({ 0 => false, 1 => true, 2 => false })
          end

          it 'checks all letters in a word' do
            # First row: A(0) M(1) I(2) G(3) O(4)
            result = cw.cell_mismatches(%w[A M I G O], indices: [0, 1, 2, 3, 4])
            expect(result.values).to all(be false)
          end

          it 'detects all incorrect letters in a word' do
            result = cw.cell_mismatches(%w[Z Z Z Z Z], indices: [0, 1, 2, 3, 4])
            expect(result.values).to all(be true)
          end
        end

        context 'full-puzzle mode (without indices)' do
          it 'returns all false when all letters are correct' do
            result = cw.cell_mismatches(cw.letters)
            expect(result.values).to all(be false)
          end

          it 'returns true for incorrect positions' do
            wrong = cw.letters.dup
            wrong[0] = 'Z'  # was 'A'
            result = cw.cell_mismatches(wrong)
            expect(result[0]).to be true
            expect(result[1]).to be false  # 'M' unchanged
          end

          it 'does not flag empty cells (spaces)' do
            blanks = ' ' * cw.letters.length
            result = cw.cell_mismatches(blanks)
            expect(result.values).to all(be false)
          end

          it 'does not flag void cells (underscores)' do
            voids = '_' * cw.letters.length
            result = cw.cell_mismatches(voids)
            expect(result.values).to all(be false)
          end

          it 'flags only filled-in incorrect cells in a partial solution' do
            partial = ' ' * cw.letters.length
            partial[0] = 'A'  # correct
            partial[1] = 'Z'  # incorrect
            result = cw.cell_mismatches(partial)
            expect(result[0]).to be false  # correct letter
            expect(result[1]).to be true   # wrong letter
            expect(result[2]).to be false  # empty (space)
          end
        end
      end

      it '#is_void_at?' do
        row = subject.random_row
        col = subject.random_col
        index = subject.index_from_rc(row, col)
        subject.letters[index - 1] = [' ','_'].sample
        expect(subject.is_void_at?(row, col)).to be true
        subject.letters[index - 1] = Faker::Lorem.characters(number: 1)
        expect(subject.is_void_at?(row, col)).to be false
        subject.letters = ''
        expect(subject.is_void_at?(row, col)).to be false
      end

      describe '#populate_letters' do
        it 'has blank letters' do
          expect(subject.letters).to be_blank
        end
        it 'has letters length equal to area' do
          expect(subject.letters.length).to eq subject.area
        end

        it 'throws error if letters are not blank' do
          expect {subject.populate_letters}.to raise_error(RuntimeError)
        end
      end
    end


    context 'requiring cells' do

      describe '#populate_cells', dirty_inside: true, skip_callbacks: true do
        subject {temp = create(:crossword, :smaller); temp.populate_cells; temp}

        it 'numbers all cells in top row' do
          top_row_cells = subject.cells.where(row: 1)
          expect(top_row_cells).to_not be_empty
          top_row_cells.each do |cell|
            expect(cell.cell_num).to eq cell.index
          end
        end
        it 'numbers all cells in left column' do
          left_column_cells = subject.cells.where(col: 1).where.not(row: 1)
          expect(left_column_cells).to_not be_empty
          left_column_cells.each do |cell|
            expect(cell.cell_num).to eq (cell.index/subject.cols + subject.cols)
          end
        end
        it 'numbers no other cells in puzzle' do
          remaining_cells = subject.cells.where.not(row: 1).where.not(col: 1)
          expect(remaining_cells).to_not be_empty
          remaining_cells.each do |cell|
            expect(cell.cell_num).to be_nil
          end
        end
        it 'throws error if already populated' do
          expect(subject.cells.count).to be > 0
          expect {subject.populate_cells}.to raise_error(RuntimeError)
        end

      end
      describe '#number_cells' do
        context 'on an unpublished crossword' do
          subject {create(:crossword, :smaller)}
          before {subject.randomize_letters_and_voids(true, true).save}

          context 'before numbering' do
            let(:need_numbers){subject.cells.select{|cell| cell.should_be_numbered?}}
            let(:no_numbers){subject.cells.select{|cell| !cell.should_be_numbered?}}
            it 'cells are not properly numbered beforehand' do
              expect(need_numbers.map(&:cell_num)).to include(nil)
            end
          end
          context 'after numbering' do
            before :each do
              subject.number_cells
              @need_numbers = subject.cells.select{|cell| cell.should_be_numbered?}
              @no_numbers = subject.cells.select{|cell| !cell.should_be_numbered?}
            end
            it 'numbers cells that need numbers' do
              cell_nums = @need_numbers.map(&:cell_num)
              expect(cell_nums).to_not include(nil)
            end
            it 'de-numbers cells that do not need numbers' do
              cell_nums = @no_numbers.map(&:cell_num)
              expect(cell_nums).to eq [nil]*cell_nums.length
            end
            it 'numbers in order, starting at 1 and incrementing by 1' do
              cell_nums = @need_numbers.map(&:cell_num)
              expect(cell_nums).to eq (1..@need_numbers.length).to_a
            end

          end
        end
      end

      describe '#randomize_letters_and_voids' do
        subject { create(:crossword, :smaller) }

        it 'does not raise when get_mirror_cell returns nil' do
          allow_any_instance_of(Cell).to receive(:get_mirror_cell).and_return(nil)
          expect { subject.randomize_letters_and_voids(true, true) }.not_to raise_error
        end
      end

      describe '#across/down_start_cells' do
        subject {create(:crossword)}
        it 'returns across start cells' do
          expect(subject.across_start_cells).to eq subject.cells.select(&:is_across_start)
        end
        it 'returns down start cells' do
          expect(subject.down_start_cells).to eq subject.cells.select(&:is_down_start)
        end
      end

      describe '#set_contents' do
        subject {create(:crossword, :smaller)}
        let(:random_string){Faker::Lorem.characters(number: subject.reload.area)}

        context 'before running' do
          it 'its cells are not set' do
            expect(subject.string_from_cells).to_not eq random_string
          end
          it 'its letters attribute is not set' do
            expect(subject.letters).to_not eq random_string
          end
        end
        context 'after running' do
          before {subject.set_contents(random_string)}
          it 'its cells are set to the argument string' do
            expect(subject.string_from_cells).to eq random_string
          end
          it 'its letters attribute is set to the argument string' do
            expect(subject.letters).to eq random_string
          end
        end
        context 'with void cells' do
          let(:void_indices){[]}
          let(:normal_indices){[]}
          before :each do
            void_indices = []
            normal_indices = []

            random_string.split('').each_with_index do |letter, i|
              die_roll = (rand*6).ceil
              case die_roll 
              when 1
                random_string[i] = '_'
                void_indices << (i+1)
              when 2
                random_string[i] = ' '
                void_indices << (i+1)
              else
                normal_indices << (i+1)
              end
            end
            subject.set_contents(random_string)
          end
          it 'has properly set is_void attributes' do
            cells = subject.cells.where(index: void_indices)
            expect(cells.map(&:is_void)).to eq [true]*cells.length
          end
          it 'does not have improperly set is_void values' do
            cells = subject.cells.where(index: normal_indices)
            expect(cells.map(&:is_void)).to eq [false]*cells.length
          end
          it 'sets the void cell letters to nil' do
            cells = subject.cells.where(index: void_indices)
            expect(cells.map(&:letters)).to eq [nil]*cells.length
          end
        end
        context 'on an invalid crossword (cannot be saved)' do
          it 'raises an error' do
            allow(subject).to receive(:save).and_return(false)
            expect{subject.set_contents(random_string)}.to raise_error 'Save failed!'
          end
        end
        it 'raises Argument Error on short argument' do
          expect{subject.set_contents(random_string[0...-1])}.to raise_error ArgumentError
        end
        it 'raises Argument Error on long argument' do
          expect{subject.set_contents(random_string+Faker::Lorem.characters(number: 1))}.to raise_error ArgumentError
        end
      end

      describe '#set_clue' do
        subject {create(:crossword)}
        let(:cell){subject.cells.where.not(cell_num: nil).sample}
        let(:clue){cell.clues.sample}
        let(:random_string){Faker::Lorem.characters(number: (1..Clue::CONTENT_LENGTH_MAX).to_a.sample)}
        let(:across){clue == cell.across_clue}
        
        it 'changes the clue text' do
          subject.set_clue(across, cell.cell_num, random_string)
          expect(clue.reload.content).to eq random_string
        end

        it 'errors when cell not found' do
          bad_cell_num = subject.area + 1
          expect{subject.set_clue(across, bad_cell_num, random_string)}.to raise_error ActiveRecord::RecordNotFound
        end
        it 'errors when clue not found' do
          if across
            cell.across_clue.destroy
          else
            cell.down_clue.destroy
          end
          expect{subject.set_clue(across, cell.cell_num, random_string)}.to raise_error ActiveRecord::RecordNotFound
        end

      end
      describe '#circles_from_array' do
        subject {create(:crossword)}
        let(:circle_count){rand(subject.area).ceil}
        let(:circle_inputs){([0]*(subject.area-circle_count)+[1]*circle_count).shuffle}

        context 'before running' do
          it 'is not circled' do
            expect(subject.circled).to be false
          end
        end
        context 'during running' do
          it 'errors if argument length greater than crossword area' do
            circle_inputs.push(circle_inputs[0])
            expect{subject.circles_from_array(circle_inputs)}.to raise_error(RuntimeError)
          end
          it 'errors if argument length less than crossword area' do
            circle_inputs.pop
            expect{subject.circles_from_array(circle_inputs)}.to raise_error(RuntimeError)
          end
          it 'errors if some cells are missing' do
            subject.cells.find_by_index(circle_inputs.index(1)+1).destroy
            expect{subject.circles_from_array(circle_inputs)}.to raise_error(ActiveRecord::RecordNotFound, 'Not all cells that needed circles were found.')
          end
        end
        context 'after running' do
          before{subject.circles_from_array(circle_inputs)}
          it 'is circled' do
            expect(subject.circled).to be true
          end
          it 'should have circled the correct cells' do
            circle_results = subject.cells.map{|cell| cell.circled ? 1 : 0}
            expect(circle_results).to eq circle_inputs
          end
        end
      end
      describe '#get_words_hsh' do
        context 'in a puzzle without repeated words' do
          subject{create(:predefined_five_by_five)}
          it 'returns a hash of words to clue arrays' do
            result = subject.get_words_hsh
            expect(result).to be_a Hash
            expect(result.keys).to all(be_a String)
          end
        end
      end

      describe '#generate_words_and_link_clues' do
        let(:crossword) { create(:predefined_five_by_five) }

        before { crossword.generate_words_and_link_clues }

        it 'creates Word records for each word in the puzzle' do
          expect(Word.where(content: 'AMIGO')).to exist
          expect(Word.where(content: 'AVAIL')).to exist
        end

        it 'links clues to their Word records' do
          across_clue = crossword.across_start_cells.first.across_clue
          expect(across_clue.reload.word).to be_present
          expect(across_clue.word.content).to eq('AMIGO')
        end

        it 'creates Phrase records for clues with meaningful content' do
          across_clue = crossword.across_start_cells.first.across_clue
          expect(across_clue.reload.phrase).to be_present
          expect(across_clue.phrase.content).to eq('A male friend')
        end

        it 'does not create Phrase records for default content clues' do
          # Reset a clue to default content and re-run
          clue = crossword.across_start_cells.first.across_clue
          clue.update_column(:content, Clue::DEFAULT_CONTENT)
          clue.update_column(:phrase_id, nil)
          clue.update_column(:word_id, nil)

          crossword.generate_words_and_link_clues
          expect(clue.reload.phrase).to be_nil
        end

        it 'deduplicates phrases case-insensitively' do
          # Set two clues to the same content with different case
          clues = crossword.across_start_cells.map(&:across_clue)
          clues[0].update_column(:content, 'A test clue')
          clues[1].update_column(:content, 'a test clue')

          crossword.generate_words_and_link_clues
          expect(clues[0].reload.phrase).to eq(clues[1].reload.phrase)
        end
      end


    end
  end

  describe 'CLASS METHODS' do
    describe '#new' do
      subject(:crossword) {build(:crossword)}
      it { is_expected.to be_a_new(Crossword) }
      it 'letters length does not equal area before populate' do
        expect(subject.letters.length).not_to eq subject.area
      end
    end

    describe '#create' do
      context 'without callbacks', skip_callbacks: true do
        subject {create(:crossword)}

        it { is_expected.not_to be_a_new(Crossword) }
        it 'has blank letters' do
          expect(subject.letters).to be_blank
        end
        it 'has no cells' do
          expect(subject.cells).to be_empty
        end

        it 'saves to database Crossword' do
          expect { subject }.to change(Crossword, :count).by(1)
        end
      end

      context 'with callbacks', dirty_inside: true do
        subject {create(:crossword)}
        it 'letters length equals area' do
          expect(subject.letters.length).to eq subject.area
        end
        it 'cells count equals area' do
          expect(subject.cells.count).to eq subject.area
        end
      end
    end
    context 'without building a Crossword' do
      it 'random_row_or_col is in range' do
        expect(Crossword.random_row_or_col).to be_in(1..Crossword::MAX_DIMENSION)
      end
      it 'random_row_or_col is an Integer' do
        expect(Crossword.random_row_or_col).to be_an Integer
      end
      it 'random_dimension is in range' do
        expect(Crossword.random_dimension).to be_in(Crossword::MIN_DIMENSION..Crossword::MAX_DIMENSION)
      end
      it 'random_dimension is an Integer' do
        expect(Crossword.random_dimension).to be_an Integer
      end
    end
  end
end
