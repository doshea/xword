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
        subject {temp = create(:crossword); temp.populate_cells; temp}

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
          subject {create(:crossword)}
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

      describe '#set_contents!' do
        subject {create(:crossword)}
        let(:random_letters){Faker::Lorem.characters(subject.reload.area)}

        context 'before running' do
          it 'its cells are not set' do
            expect(subject.string_from_cells).to_not eq random_letters
          end
          it 'its letters attribute is not set' do
            expect(subject.letters).to_not eq random_letters
          end
        end
        context 'after running' do
          before {subject.set_contents!(random_letters)}
          it 'its cells are set to the argument string' do
            expect(subject.string_from_cells).to eq random_letters
          end
          it 'its letters attribute is set to the argument string' do
            expect(subject.letters).to eq random_letters
          end
        end
        context 'on a published crossword' do
          subject {create(:crossword, :published)}
          it 'raises an error' do
            expect{subject.set_contents(random_letters)}.to raise_error
          end
        end
        context 'on an invalid crossword (cannot be saved)' do
          it 'raises an error' do
            subject.rows = 0
            expect{subject.set_contents(random_letters)}.to raise_error
          end
        end
        it 'raises Argument Error on short argument' do
          expect{subject.set_contents!(random_letters[0...-1])}.to raise_error ArgumentError
        end
        it 'raises Argument Error on long argument' do
          expect{subject.set_contents!(random_letters+Faker::Lorem.characters(1))}.to raise_error ArgumentError
        end
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
