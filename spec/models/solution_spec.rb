# == Schema Information
#
# Table name: solutions
#
#  id           :integer          not null, primary key
#  letters      :text             default(""), not null
#  is_complete  :boolean          default(FALSE), not null
#  user_id      :integer
#  crossword_id :integer
#  created_at   :datetime
#  updated_at   :datetime
#  team         :boolean          default(FALSE), not null
#  key          :string(255)
#  solved_at    :datetime
#

describe Solution do
  let(:crossword) { create(:crossword, :smaller) }
  let(:user)      { create(:user) }

  context 'associations' do
    it {should belong_to(:user).optional}
    it {should belong_to(:crossword).optional}
    it {should have_many(:solution_partnerings).dependent(:destroy)}
    it {should have_many(:teammates).through(:solution_partnerings).source(:user)}
  end

  describe '#check_completion (before_save callback)' do
    context 'when letters match the crossword' do
      it 'marks the solution as complete and sets solved_at' do
        solution = create(:solution, :complete, user: user, crossword: crossword)
        expect(solution.is_complete).to be true
        expect(solution.solved_at).to be_present
      end
    end

    context 'when letters do not match' do
      it 'leaves is_complete as false' do
        solution = create(:solution, user: user, crossword: crossword, letters: '')
        expect(solution.is_complete).to be false
      end
    end
  end

  describe '#percent_complete' do
    it 'returns a hash with numerator, denominator, and percent keys' do
      solution = create(:solution, user: user, crossword: crossword)
      result = solution.percent_complete
      expect(result).to include(:numerator, :denominator, :percent)
    end

    it 'returns a numeric percent' do
      solution = create(:solution, user: user, crossword: crossword)
      expect(solution.percent_complete[:percent]).to be_a(Numeric)
    end
  end

  describe '#fill_letters' do
    it 'reinitializes letters when length does not match the crossword' do
      solution = create(:solution, user: user, crossword: crossword, letters: '')
      solution.fill_letters
      expect(solution.reload.letters.length).to eq crossword.letters.length
    end
  end
end
