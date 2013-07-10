# == Schema Information
#
# Table name: clues
#
#  id         :integer          not null, primary key
#  content    :text             default("ENTER CLUE")
#  difficulty :integer          default(1)
#  user_id    :integer
#  word_id    :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'spec_helper'

describe Clue do
  describe '.new' do
    it 'creates an instance of User' do

    end
  end
  describe 'associations' do
    it {should belong_to :user}
    it {should have_many :across_cells}
    it {should have_many :down_cells}
    it {should have_many(:crosswords).through(:across_cells)}
    it {should have_many(:crosswords).through(:down_cells)}
  end
end
