RSpec.describe 'POST /crosswords/:id/reveal', type: :request do
  let_it_be(:crossword) { create(:crossword) }
  let(:user) { create(:user, :with_test_password) }
  let(:solution) { Solution.find_or_create_by(crossword: crossword, user: user, team: false) }

  # First non-void cell index
  let(:first_letter_index) do
    crossword.letters.chars.each_with_index.find { |c, _| c != '_' }&.last || 0
  end

  before { solution.fill_letters }

  describe 'as a logged-in user' do
    before { log_in_as(user) }

    it 'returns the correct letter for a single cell' do
      post "/crosswords/#{crossword.id}/reveal",
           params: { indices: [first_letter_index], solution_id: solution.id }
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expected_letter = crossword.letters[first_letter_index]
      expect(json['letters'][first_letter_index.to_s]).to eq(expected_letter)
    end

    it 'increments hints_used on the solution' do
      expect {
        post "/crosswords/#{crossword.id}/reveal",
             params: { indices: [first_letter_index], solution_id: solution.id }
      }.to change { solution.reload.hints_used }.by(1)
    end

    it 'increments by word length for multiple indices' do
      # Grab first 3 non-void indices
      indices = crossword.letters.chars.each_with_index
                  .select { |c, _| c != '_' }.first(3).map(&:last)
      expect {
        post "/crosswords/#{crossword.id}/reveal",
             params: { indices: indices, solution_id: solution.id }
      }.to change { solution.reload.hints_used }.by(indices.size)
    end

    it 'skips void cells and does not count them as hints' do
      void_index = crossword.letters.index('_')
      skip 'No void cells in test crossword' unless void_index
      post "/crosswords/#{crossword.id}/reveal",
           params: { indices: [void_index], solution_id: solution.id }
      json = JSON.parse(response.body)
      expect(json['letters']).to be_empty
      expect(solution.reload.hints_used).to eq(0)
    end

    it 'returns 400 with no indices' do
      post "/crosswords/#{crossword.id}/reveal", params: { solution_id: solution.id }
      expect(response).to have_http_status(:bad_request)
    end

    it 'ignores out-of-range indices' do
      post "/crosswords/#{crossword.id}/reveal",
           params: { indices: [-1, 9999], solution_id: solution.id }
      json = JSON.parse(response.body)
      expect(json['letters']).to be_empty
    end

    it 'does not increment hints when no valid cells are revealed' do
      expect {
        post "/crosswords/#{crossword.id}/reveal",
             params: { indices: [-1], solution_id: solution.id }
      }.not_to change { solution.reload.hints_used }
    end

    it 'persists revealed_indices on the solution' do
      post "/crosswords/#{crossword.id}/reveal",
           params: { indices: [first_letter_index], solution_id: solution.id }
      expect(JSON.parse(solution.reload.revealed_indices)).to include(first_letter_index)
    end

    it 'merges revealed_indices without duplicates on repeated reveals' do
      post "/crosswords/#{crossword.id}/reveal",
           params: { indices: [first_letter_index], solution_id: solution.id }
      post "/crosswords/#{crossword.id}/reveal",
           params: { indices: [first_letter_index], solution_id: solution.id }
      stored = JSON.parse(solution.reload.revealed_indices)
      expect(stored.count(first_letter_index)).to eq(1)
    end

    it 'accumulates revealed_indices across separate reveals' do
      indices = crossword.letters.chars.each_with_index
                  .select { |c, _| c != '_' }.first(2).map(&:last)
      post "/crosswords/#{crossword.id}/reveal",
           params: { indices: [indices[0]], solution_id: solution.id }
      post "/crosswords/#{crossword.id}/reveal",
           params: { indices: [indices[1]], solution_id: solution.id }
      stored = JSON.parse(solution.reload.revealed_indices)
      expect(stored).to include(indices[0], indices[1])
    end

    it 'does not persist revealed_indices when no valid cells are revealed' do
      post "/crosswords/#{crossword.id}/reveal",
           params: { indices: [-1], solution_id: solution.id }
      expect(JSON.parse(solution.reload.revealed_indices)).to be_empty
    end
  end

  describe 'as an anonymous user' do
    it 'returns the correct letter (no auth required)' do
      post "/crosswords/#{crossword.id}/reveal",
           params: { indices: [first_letter_index] }
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['letters'][first_letter_index.to_s]).to eq(crossword.letters[first_letter_index])
    end
  end

  describe 'as a team partner' do
    let(:owner) { create(:user, :with_test_password) }
    let(:team_solution) { Solution.create!(crossword: crossword, user: owner, team: true) }

    before do
      team_solution.fill_letters
      SolutionPartnering.create!(solution: team_solution, user: user)
      log_in_as(user)
    end

    it 'increments hints_used on the team solution' do
      expect {
        post "/crosswords/#{crossword.id}/reveal",
             params: { indices: [first_letter_index], solution_id: team_solution.id }
      }.to change { team_solution.reload.hints_used }.by(1)
    end

    it 'persists revealed_indices on the team solution' do
      post "/crosswords/#{crossword.id}/reveal",
           params: { indices: [first_letter_index], solution_id: team_solution.id }
      expect(JSON.parse(team_solution.reload.revealed_indices)).to include(first_letter_index)
    end
  end
end
