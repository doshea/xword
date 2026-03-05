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
    it { is_expected.to belong_to :user }
    it { is_expected.to belong_to :solution }
    it { is_expected.to have_one(:crossword).through(:solution) }
  end
end
