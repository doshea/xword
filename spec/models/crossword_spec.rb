# == Schema Information
#
# Table name: crosswords
#
#  id           :integer          not null, primary key
#  title        :string(255)      default("Untitled"), not null
#  letters      :text             default(""), not null
#  description  :text
#  rows         :integer          default(15), not null
#  cols         :integer          default(15), not null
#  published    :boolean          default(FALSE), not null
#  published_at :datetime
#  user_id      :integer
#  created_at   :datetime
#  updated_at   :datetime
#  circled      :boolean          default(FALSE)
#  preview      :text
#

describe Crossword do
  it 'has a valid factory' do
    create(:crossword).should be_valid
  end

  describe 'associations' do
    it {should belong_to :user}
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
    it {should have_and_belong_to_many(:potential_words).class_name('Word')}
  end

  describe 'attributes' do

  end

  describe 'validations' do
    it { should validate_presence_of(:rows)}
    it { should validate_numericality_of(:rows).only_integer}
    it { should ensure_inclusion_of(:rows).in_range(Crossword::MIN_DIMENSION..Crossword::MAX_DIMENSION)}
    it { should validate_presence_of(:cols)}
    it { should validate_numericality_of(:cols).only_integer}
    it { should ensure_inclusion_of(:cols).in_range(Crossword::MIN_DIMENSION..Crossword::MAX_DIMENSION)}
    it { should validate_presence_of(:title)}
    it { should ensure_length_of(:title).is_at_least(Crossword::MIN_TITLE_LENGTH).is_at_most(Crossword::MAX_TITLE_LENGTH) }
  end

  describe 'INSTANCE METHODS' do
    context 'no requirements' do
      subject {build(:crossword)}

      its(:random_row){should be_in(1..subject.rows)}
      its(:random_row){should be_an Integer}
      its(:random_col){should be_in(1..subject.cols)}
      its(:random_col){should be_an Integer}
      its(:random_index){should be_in(1..subject.area)}
      its(:random_index){should be_an Integer}

      describe "helpers for index/row/col" do
        it 'interconvert properly' do
          index = subject.random_index
          row = subject.row_from_index(index)
          col = subject.col_from_index(index)
          expect(subject.index_from_rc(row, col)).to eq index
        end
        describe '#index_from_rc' do
          it 'raises error on too-high row' do
            expect{subject.index_from_rc(subject.rows * 2, subject.random_col)}.to raise_error
          end
          it 'raises error on too-low row' do
            expect{subject.index_from_rc(subject.rows * -1, subject.random_col)}.to raise_error
          end
          it 'raises error on too-high col' do
            expect{subject.index_from_rc(subject.random_row, subject.cols * 2)}.to raise_error
          end
          it 'raises error on too-low col' do
            expect{subject.index_from_rc(subject.random_row, matsubject.cols * -1)}.to raise_error
          end
        end
        describe '#row_from_index' do
          it 'raises error on too-high index' do
            expect{subject.row_from_index(subject.rows*subject.cols*2)}.to raise_error
          end
          it 'raises error on too-low index' do
            expect{subject.row_from_index(subject.rows*subject.cols*-1)}.to raise_error
          end
        end
        describe '#col_from_index' do
          it 'raises error on too-high index' do
            expect{subject.col_from_index(subject.rows*subject.cols*2)}.to raise_error
          end
          it 'raises error on too-low index' do
            expect{subject.col_from_index(subject.rows*subject.cols*-1)}.to raise_error
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
        its(:nonvoid_letter_count){ should be > 0}
        its(:nonvoid_letter_count){ should eq (subject.letters.length - subject.letters.count(' _'))}
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
            subject.get_mismatches(@similar_letters).should eq mismatches
          end

          it 'returns empty array if the solutions match' do
            subject.get_mismatches(subject.letters).should eq []
          end

          it 'raise an error when the solution is improperly sized' do
            #either halves or doubles the solution
            bad_letters = rand.round.even? ? subject.letters*2 : subject.letters[subject.letters.length/2,subject.letters.length/2]
            expect{subject.get_mismatches(bad_letters)}.to raise_error
          end
        end

      end

      it '#is_void_at?' do
        row = subject.random_row
        col = subject.random_col
        index = subject.index_from_rc(row, col)
        subject.letters[index - 1] = [' ','_'].sample
        expect(subject.is_void_at?(row, col)).to be true
        subject.letters[index - 1] = Faker::Lorem.characters(1)
        expect(subject.is_void_at?(row, col)).to be false
        subject.letters = ''
        expect(subject.is_void_at?(row, col)).to be false
      end

      describe '#populate_letters' do
        its(:letters){ should be_blank}
        its('letters.length'){ should eq subject.area}

        it 'throws error if letters are not blank' do
          expect {subject.populate_letters}.to raise_error
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
          subject.cells.count.should be > 0
          expect {subject.populate_cells}.to raise_error
        end
        context 'if published' do
          subject {temp = create(:crossword, :published); temp.populate_cells; temp}
          it 'errors' do
            expect {subject.populate_cells}.to raise_error
          end
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

        context 'on a published crossword' do
          subject{create(:crossword, :published)}
          it 'raises an error' do
            expect{subject.number_cells}.to raise_error
          end
        end
      end

      describe '#across/down_start_cells' do
        subject {create(:crossword)}
        its(:across_start_cells){should eq subject.cells.select(&:is_across_start)}
        its(:down_start_cells){should eq subject.cells.select(&:is_down_start)}
      end

      describe '#set_contents' do
        subject {create(:crossword, :smaller)}
        let(:random_string){Faker::Lorem.characters(subject.reload.area)}

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
        context 'on a published crossword' do
          subject {create(:crossword, :published)}
          it 'raises an error' do
            expect{subject.set_contents(random_string)}.to raise_error
          end
        end
        context 'on an invalid crossword (cannot be saved)' do
          it 'raises an error' do
            subject.stub(:save){false}
            expect{subject.set_contents(random_string)}.to raise_error 'Save failed!'
          end
        end
        it 'raises Argument Error on short argument' do
          expect{subject.set_contents(random_string[0...-1])}.to raise_error ArgumentError
        end
        it 'raises Argument Error on long argument' do
          expect{subject.set_contents(random_string+Faker::Lorem.characters(1))}.to raise_error ArgumentError
        end
      end

      describe '#set_clue' do
        subject {create(:crossword)}
        let(:cell){subject.cells.where.not(cell_num: nil).sample}
        let(:clue){cell.clues.sample}
        let(:random_string){Faker::Lorem.characters((1..Clue::CONTENT_LENGTH_MAX).to_a.sample)}
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
      describe '#build_seed' do

      end
      describe '#circles_from_array' do
        subject {create(:crossword)}
        let(:circle_count){rand(subject.area).ceil}
        let(:circle_inputs){([0]*(subject.area-circle_count)+[1]*circle_count).shuffle}

        context 'before running' do
          its(:circled){should be_false}
        end
        context 'during running' do
          it 'errors if argument length greater than crossword area' do
            circle_inputs.push(circle_inputs[0])
            expect{subject.circles_from_array(circle_inputs)}.to raise_error
          end
          it 'errors if argument length less than crossword area' do
            circle_inputs.pop
            expect{subject.circles_from_array(circle_inputs)}.to raise_error
          end
          it 'errors if some cells are missing' do
            subject.cells.find_by_index(circle_inputs.index(1)+1).destroy
            expect{subject.circles_from_array(circle_inputs)}.to raise_error(ActiveRecord::RecordNotFound, 'Not all cells that needed circles were found.')
          end
        end
        context 'after running' do
          before{subject.circles_from_array(circle_inputs)}
          its(:circled){should be_true}
          it 'should have circled the correct cells' do
            circle_results = subject.cells.map{|cell| cell.circled ? 1 : 0}
            expect(circle_results).to eq circle_inputs
          end
        end
      end
      describe '#generate_preview' do

      end
      describe '#get_words_hsh', in_prog: true do
        context 'in a puzzle without repeated words' do
          subject{create(:predefined_five_by_five)}
          it 'works'
        end
        context 'in a puzzle with repeated words' do

          subject{create(:repeating_five_by_five)}
          it 'works' do
            pending
            binding.pry
            expected_return = {
              'WORLD' => [Clue.find_by_content('complete environment'), Clue.find_by_content('planet')],
              'OTHER' => [Clue.find_by_content('not this one'), Clue.find_by_content('alien')],
              'RHYME' => [Clue.find_by_content('poetic device'), Clue.find_by_content('similar sounder')],
              'LEMMA' => [Clue.find_by_content('assumption'), Clue.find_by_content("with 'dil', a sticky situation")],
              'DREAD' => [Clue.find_by_content('foreboding'), Clue.find_by_content('apprehensive fear)')]
            }
            actual_return = subject.get_words_hsh
            # actual_return.each_key{|k| actual_return[k] = actual_return[k].map(&:content)}
            actual_return.should eq expected_return
          end
        end
      end
      describe '#generate_words_and_link_clues' do

      end




    end
  end

  describe 'CLASS METHODS' do
    describe '#new' do
      subject(:crossword) {build(:crossword)}
      it {should be_a_new(Crossword)}
      its('letters.length'){should_not eq subject.area}
    end

    describe '#create' do
      context 'without callbacks', skip_callbacks: true do
        subject {create(:crossword)}

        it {should_not be_a_new(Crossword)}
        its(:letters){ should be_blank}
        its(:cells){should be_empty}

        it 'saves to database Crossword' do
          subject #ensure that it is present
          Crossword.count.should eq 1
          create(:crossword)
          Crossword.count.should eq 2
        end
      end

      context 'with callbacks', dirty_inside: true do
        subject {create(:crossword)}
        its('letters.length'){should eq subject.area}
        its('cells.count'){should eq subject.area}
      end
    end
    context 'without building a Crossword' do
      subject {Crossword}
      its(:random_row_or_col){ should be_in (1..Crossword::MAX_DIMENSION)}
      its(:random_row_or_col){ should be_an Integer}
      its(:random_dimension){ should be_in (Crossword::MIN_DIMENSION  ..Crossword::MAX_DIMENSION)}
      its(:random_dimension){ should be_an Integer}
    end
  end
end
