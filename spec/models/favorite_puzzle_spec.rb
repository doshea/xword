# == Schema Information
#
# Table name: favorite_puzzles
#
#  id           :integer          not null, primary key
#  crossword_id :integer          not null
#  user_id      :integer          not null
#  created_at   :datetime
#  updated_at   :datetime
#

describe FavoritePuzzle do
  context 'associations' do
    it {should belong_to :crossword}
    it {should belong_to :user}
  end
end
