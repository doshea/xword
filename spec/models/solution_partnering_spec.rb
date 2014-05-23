# == Schema Information
#
# Table name: solution_partnerings
#
#  id          :integer          not null, primary key
#  user_id     :integer          not null
#  solution_id :integer          not null
#  created_at  :datetime
#  updated_at  :datetime
#

describe SolutionPartnering do
  context 'associations' do
    it { should belong_to :user }
    it { should belong_to :solution }
    it { should have_one(:crossword).through(:solution) }
  end
end
