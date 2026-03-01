# == Schema Information
#
# Table name: words
#
#  id         :integer          not null, primary key
#  content    :string(255)
#  created_at :datetime
#  updated_at :datetime
#

describe Word do
  context 'associations' do
    it {should have_many :clues}
    it {should have_many :across_cells}
    it {should have_many :down_cells}
    it {should have_many(:across_crosswords).through(:across_cells).source(:crossword) }
    it {should have_many(:down_crosswords).through(:down_cells).source(:crossword) }
  end
end
