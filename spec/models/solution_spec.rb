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
    it { is_expected.to belong_to(:user).optional}
    it { is_expected.to belong_to(:crossword).optional}
    it { is_expected.to have_many(:solution_partnerings).dependent(:destroy)}
    it { is_expected.to have_many(:teammates).through(:solution_partnerings).source(:user)}
  end

  context 'validations' do
    it 'rejects letters longer than the maximum crossword area' do
      solution = build(:solution, user: user, crossword: crossword, letters: 'A' * 901)
      expect(solution).not_to be_valid
      expect(solution.errors[:letters]).to be_present
    end
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

  describe '#hints_used' do
    it 'defaults to 0' do
      solution = create(:solution, user: user, crossword: crossword)
      expect(solution.hints_used).to eq(0)
    end
  end

  describe '#fill_letters' do
    it 'reinitializes letters when length does not match the crossword' do
      solution = create(:solution, user: user, crossword: crossword, letters: '')
      solution.fill_letters
      expect(solution.reload.letters.length).to eq crossword.letters.length
    end
  end

  describe '#accessible_by?' do
    let(:solution) { create(:solution, user: user, crossword: crossword) }
    let(:partner)  { create(:user) }
    let(:outsider) { create(:user) }

    before do
      SolutionPartnering.create!(solution: solution, user: partner)
    end

    it 'returns true for the owner' do
      expect(solution.accessible_by?(user)).to be true
    end

    it 'returns true for a team partner' do
      expect(solution.accessible_by?(partner)).to be true
    end

    it 'returns false for an outsider' do
      expect(solution.accessible_by?(outsider)).to be false
    end

    it 'returns false for nil' do
      expect(solution.accessible_by?(nil)).to be false
    end
  end

  describe 'zero-letter crossword (all voids)' do
    let(:void_crossword) do
      cw = create(:crossword, :smaller)
      cw.update_column(:letters, '_' * cw.letters.length)
      cw
    end
    let(:solution) { create(:solution, user: user, crossword: void_crossword, letters: '_' * void_crossword.letters.length) }

    it '#percent_complete returns zeroed hash without dividing by zero' do
      expect(solution.percent_complete).to eq({ numerator: 0, denominator: 0, percent: 0.0 })
    end

    it '#percent_correct returns zeroed hash without dividing by zero' do
      expect(solution.percent_correct).to eq({ numerator: 0, denominator: 0, percent: 0.0 })
    end
  end

  describe 'nil-crossword safety (orphaned solution)' do
    let(:orphaned) do
      s = create(:solution, user: user, crossword: crossword, letters: '')
      s.update_column(:crossword_id, nil)
      s.reload
    end

    it '#check_completion returns true without raising' do
      expect(orphaned.check_completion).to eq true
    end

    it '#percent_complete returns zeroed hash' do
      expect(orphaned.percent_complete).to eq({ numerator: 0, denominator: 0, percent: 0.0 })
    end

    it '#percent_correct returns zeroed hash' do
      expect(orphaned.percent_correct).to eq({ numerator: 0, denominator: 0, percent: 0.0 })
    end

    it '#fill_letters returns nil without raising' do
      expect(orphaned.fill_letters).to be_nil
    end
  end
end
