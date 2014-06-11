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

  end

  describe 'INSTANCE METHODS' do

    context 'requiring letters' do
      subject {build(:crossword)}
      before {subject.populate_letters}
      after {subject.letters = ''}

      its(:nonvoid_letter_count){ should eq (subject.letters.length - subject.letters.count(' _'))}
      it '#is_void_at?' do
        row = subject.random_row
        col = subject.random_col
        index = subject.rc_to_index(row, col)
        expect(subject.is_void_at?(row, col)).to be false
        subject.letters[index - 1] = '_'
        expect(subject.is_void_at?(row, col)).to be true
      end

      describe '#populate_letters' do
        its(:letters){ should be_blank}
        its('letters.length'){ should eq subject.area}
      end
    end


    context 'requiring cells' do

      describe '#populate_cells', dirty_inside: true, skip_callbacks: true do
        subject {temp = create(:crossword); temp.populate_cells; temp}

        before :all do
          @crossword = create(:crossword)
          @crossword.populate_cells
          @crossword.cells
        end

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
            binding.pry if cell.cell_num != (cell.index/subject.cols + subject.cols)
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

      end
    end
  end

  context 'CLASS METHODS' do
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
      its(:random_dimension){ should be_in (Crossword::MIN_DIMENSION  ..Crossword::MAX_DIMENSION)}
    end
    

  end
end
