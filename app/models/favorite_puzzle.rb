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

class FavoritePuzzle < ActiveRecord::Base
  attr_accessible :crossword_id, :user_id
  belongs_to :crossword, inverse_of: :favorite_puzzles
  belongs_to :user, inverse_of: :favorite_puzzles
end
