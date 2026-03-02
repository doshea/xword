# == Schema Information
#
# Table name: clues
#
#  id         :integer          not null, primary key
#  content    :text             default("ENTER CLUE")
#  difficulty :integer          default(1)
#  user_id    :integer
#  word_id    :integer
#  phrase_id  :integer
#

describe Clue do
  context 'associations' do
    it {should belong_to(:user).optional}
    it {should have_many :across_cells}
    it {should have_many :down_cells}
    it {should have_many(:across_crosswords).through(:across_cells).source(:crossword)}
    it {should have_many(:down_crosswords).through(:down_cells).source(:crossword)}
  end
end
