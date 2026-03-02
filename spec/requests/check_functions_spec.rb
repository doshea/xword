RSpec.describe 'Check functions', type: :request do
  let(:test_password) { 'password123' }
  let(:user)      { create(:user, password: test_password, password_confirmation: test_password) }
  let(:crossword) { create(:predefined_five_by_five) }
  # 5x5 grid, correct letters = 'AMIGOVOLOWANIONIDOSELONER' (25 chars, 0-indexed)
  let(:correct_letters) { crossword.letters }
  let(:blank_letters)   { correct_letters.gsub(/[^_]/, ' ') }

  def log_in_as(u)
    post '/login', params: { username: u.username, password: test_password }
  end

  # jQuery AJAX headers matching $.ajax({ dataType: 'script', type: 'POST' })
  let(:xhr_headers) do
    { 'Accept' => 'text/javascript', 'X-Requested-With' => 'XMLHttpRequest' }
  end

  # ---------------------------------------------------------------------------
  # POST /crosswords/:id/check_cell — solo mode
  # ---------------------------------------------------------------------------
  describe 'POST /crosswords/:id/check_cell (solo)' do
    before { log_in_as(user) }

    context 'single cell (correct letter)' do
      it 'returns 200 with the cell marked as not incorrect' do
        post "/crosswords/#{crossword.id}/check_cell",
             params: { letters: ['A'], indices: ['0'] },
             headers: xhr_headers

        expect(response).to have_http_status(:ok)
        expect(response.body).to include('mismatches[0] = false')
      end
    end

    context 'single cell (incorrect letter)' do
      it 'returns 200 with the cell marked as incorrect' do
        post "/crosswords/#{crossword.id}/check_cell",
             params: { letters: ['Z'], indices: ['0'] },
             headers: xhr_headers

        expect(response).to have_http_status(:ok)
        expect(response.body).to include('mismatches[0] = true')
      end
    end

    context 'word check (multiple indices with mixed results)' do
      it 'returns correct/incorrect status for each cell in the word' do
        # First row: A(0) M(1) I(2) G(3) O(4) — send correct except index 1
        post "/crosswords/#{crossword.id}/check_cell",
             params: { letters: %w[A Z I G O], indices: %w[0 1 2 3 4] },
             headers: xhr_headers

        expect(response).to have_http_status(:ok)
        expect(response.body).to include('mismatches[0] = false')
        expect(response.body).to include('mismatches[1] = true')
        expect(response.body).to include('mismatches[2] = false')
        expect(response.body).to include('mismatches[3] = false')
        expect(response.body).to include('mismatches[4] = false')
      end
    end

    context 'full puzzle check (no indices)' do
      it 'returns all false when every letter is correct' do
        post "/crosswords/#{crossword.id}/check_cell",
             params: { letters: correct_letters },
             headers: xhr_headers

        expect(response).to have_http_status(:ok)
        # No position should be marked as incorrect
        expect(response.body).not_to include('= true')
      end

      it 'flags incorrect letters and skips empty cells' do
        partial = blank_letters.dup
        partial[0] = 'A'  # correct
        partial[1] = 'Z'  # incorrect

        post "/crosswords/#{crossword.id}/check_cell",
             params: { letters: partial },
             headers: xhr_headers

        expect(response).to have_http_status(:ok)
        expect(response.body).to include('mismatches[0] = false')  # correct
        expect(response.body).to include('mismatches[1] = true')   # wrong
        expect(response.body).to include('mismatches[2] = false')  # empty space — not flagged
      end
    end
  end

  # ---------------------------------------------------------------------------
  # POST /crosswords/:id/check_cell — anonymous mode
  # ---------------------------------------------------------------------------
  describe 'POST /crosswords/:id/check_cell (anonymous)' do
    it 'works without authentication' do
      post "/crosswords/#{crossword.id}/check_cell",
           params: { letters: ['A'], indices: ['0'] },
           headers: xhr_headers

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('mismatches[0] = false')
    end
  end

  # ---------------------------------------------------------------------------
  # POST /crosswords/:id/check_cell — team mode
  # ---------------------------------------------------------------------------
  describe 'POST /crosswords/:id/check_cell (team)' do
    let(:owner)         { create(:user, password: test_password, password_confirmation: test_password) }
    let(:team_solution) { create(:solution, :team, user: owner, crossword: crossword, letters: blank_letters) }

    before do
      SolutionPartnering.create!(user: user, solution: team_solution)
      log_in_as(user)
    end

    it 'checks cells against the crossword answer (not the team solution)' do
      # Team partner checks a cell — should validate against crossword.letters
      post "/crosswords/#{crossword.id}/check_cell",
           params: { letters: ['A'], indices: ['0'] },
           headers: xhr_headers

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('mismatches[0] = false')
    end

    it 'detects incorrect letters in team mode' do
      post "/crosswords/#{crossword.id}/check_cell",
           params: { letters: ['Z'], indices: ['0'] },
           headers: xhr_headers

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('mismatches[0] = true')
    end

    it 'handles full puzzle check in team mode' do
      # All correct letters
      post "/crosswords/#{crossword.id}/check_cell",
           params: { letters: correct_letters },
           headers: xhr_headers

      expect(response).to have_http_status(:ok)
      expect(response.body).not_to include('= true')
    end
  end

  # ---------------------------------------------------------------------------
  # POST /crosswords/:id/check_completion — solo mode
  # ---------------------------------------------------------------------------
  describe 'POST /crosswords/:id/check_completion (solo)' do
    let!(:solution) { create(:solution, user: user, crossword: crossword, letters: blank_letters) }

    before { log_in_as(user) }

    context 'with correct solution' do
      it 'returns JavaScript that shows the win modal' do
        post "/crosswords/#{crossword.id}/check_completion",
             params: { letters: correct_letters, solution_id: solution.id },
             headers: xhr_headers

        expect(response).to have_http_status(:ok)
        expect(response.body).to include('showModal()')
      end
    end

    context 'with incorrect solution' do
      it 'returns JavaScript that shows an alert' do
        wrong = correct_letters.dup
        wrong[0] = 'Z'

        post "/crosswords/#{crossword.id}/check_completion",
             params: { letters: wrong, solution_id: solution.id },
             headers: xhr_headers

        expect(response).to have_http_status(:ok)
        expect(response.body).to include('incorrect letters')
      end
    end

    context 'with partially filled solution (spaces remain)' do
      it 'returns incorrect since spaces do not match letters' do
        post "/crosswords/#{crossword.id}/check_completion",
             params: { letters: blank_letters, solution_id: solution.id },
             headers: xhr_headers

        expect(response).to have_http_status(:ok)
        expect(response.body).to include('incorrect letters')
      end
    end
  end

  # ---------------------------------------------------------------------------
  # POST /crosswords/:id/check_completion — anonymous mode
  # ---------------------------------------------------------------------------
  describe 'POST /crosswords/:id/check_completion (anonymous)' do
    it 'evaluates correctness without requiring authentication' do
      post "/crosswords/#{crossword.id}/check_completion",
           params: { letters: correct_letters },
           headers: xhr_headers

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('showModal()')
    end

    it 'detects incorrect solution for anonymous users' do
      post "/crosswords/#{crossword.id}/check_completion",
           params: { letters: 'Z' * correct_letters.length },
           headers: xhr_headers

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('incorrect letters')
    end
  end

  # ---------------------------------------------------------------------------
  # POST /crosswords/:id/check_completion — team mode
  # ---------------------------------------------------------------------------
  describe 'POST /crosswords/:id/check_completion (team)' do
    let(:owner)         { create(:user, password: test_password, password_confirmation: test_password) }
    let(:team_solution) { create(:solution, :team, user: owner, crossword: crossword, letters: blank_letters) }

    before do
      SolutionPartnering.create!(user: user, solution: team_solution)
      log_in_as(user)
    end

    it 'shows win modal when team solution letters are all correct' do
      post "/crosswords/#{crossword.id}/check_completion",
           params: { letters: correct_letters, solution_id: team_solution.id },
           headers: xhr_headers

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('showModal()')
    end

    it 'shows alert when team solution has incorrect letters' do
      wrong = correct_letters.dup
      wrong[0] = 'Z'

      post "/crosswords/#{crossword.id}/check_completion",
           params: { letters: wrong, solution_id: team_solution.id },
           headers: xhr_headers

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('incorrect letters')
    end
  end
end
