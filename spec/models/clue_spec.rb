# == Schema Information
#
# Table name: clues
#
#  id         :integer          not null, primary key
#  content    :string(255)      default("ENTER CLUE")
#  difficulty :integer          default(1)
#  user_id    :integer
#  word_id    :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  phrase_id  :integer
#

require 'spec_helper'

describe Clue do
  subject(:clue) { create(:clue) }
  it 'creates an instance of Clue' do

  end
  context 'associations' do
    it {should belong_to :user}
    it {should have_many :across_cells}
    it {should have_many :down_cells}
    it {should have_many(:across_crosswords).through(:across_cells)}
    it {should have_many(:down_crosswords).through(:down_cells)}
  end
  context 'attributes' do

  end
  context 'validations' do

  end
  context 'instance methods' do

  end
  context 'class methods' do

  end
end
