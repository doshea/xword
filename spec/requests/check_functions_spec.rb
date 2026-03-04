RSpec.describe 'Check functions', type: :request do
  let_it_be(:user)      { create(:user, :with_test_password) }
  let_it_be(:crossword) { create(:predefined_five_by_five) }
  # 5x5 grid, correct letters = 'AMIGOVOLOWANIONIDOSELONER' (25 chars, 0-indexed)
  let(:correct_letters) { crossword.letters }
  let(:blank_letters)   { correct_letters.gsub(/[^_]/, ' ') }

  # Primary path: JSON (current client uses dataType: 'json')
  let(:json_headers) do
    { 'Accept' => 'application/json', 'X-Requested-With' => 'XMLHttpRequest' }
  end

  # Legacy fallback: JS (dataType: 'script' via globalEval)
  let(:js_headers) do
    { 'Accept' => 'text/javascript', 'X-Requested-With' => 'XMLHttpRequest' }
  end

  # ---------------------------------------------------------------------------
  # POST /crosswords/:id/check_cell — solo mode (JSON)
  # ---------------------------------------------------------------------------
  describe 'POST /crosswords/:id/check_cell (solo)' do
    before { log_in_as(user) }

    context 'single cell (correct letter)' do
      it 'returns JSON with the cell marked as not incorrect' do
        post "/crosswords/#{crossword.id}/check_cell",
             params: { letters: ['A'], indices: ['0'] },
             headers: json_headers

        expect(response).to have_http_status(:ok)
        body = JSON.parse(response.body)
        expect(body['mismatches']['0']).to be false
      end
    end

    context 'single cell (incorrect letter)' do
      it 'returns JSON with the cell marked as incorrect' do
        post "/crosswords/#{crossword.id}/check_cell",
             params: { letters: ['Z'], indices: ['0'] },
             headers: json_headers

        expect(response).to have_http_status(:ok)
        body = JSON.parse(response.body)
        expect(body['mismatches']['0']).to be true
      end
    end

    context 'word check (multiple indices with mixed results)' do
      it 'returns correct/incorrect status for each cell in the word' do
        # First row: A(0) M(1) I(2) G(3) O(4) — send correct except index 1
        post "/crosswords/#{crossword.id}/check_cell",
             params: { letters: %w[A Z I G O], indices: %w[0 1 2 3 4] },
             headers: json_headers

        expect(response).to have_http_status(:ok)
        body = JSON.parse(response.body)
        expect(body['mismatches']['0']).to be false
        expect(body['mismatches']['1']).to be true
        expect(body['mismatches']['2']).to be false
        expect(body['mismatches']['3']).to be false
        expect(body['mismatches']['4']).to be false
      end
    end

    context 'full puzzle check (no indices)' do
      it 'returns all false when every letter is correct' do
        post "/crosswords/#{crossword.id}/check_cell",
             params: { letters: correct_letters },
             headers: json_headers

        expect(response).to have_http_status(:ok)
        body = JSON.parse(response.body)
        expect(body['mismatches'].values).to all(be false)
      end

      it 'flags incorrect letters and skips empty cells' do
        partial = blank_letters.dup
        partial[0] = 'A'  # correct
        partial[1] = 'Z'  # incorrect

        post "/crosswords/#{crossword.id}/check_cell",
             params: { letters: partial },
             headers: json_headers

        expect(response).to have_http_status(:ok)
        body = JSON.parse(response.body)
        expect(body['mismatches']['0']).to be false  # correct
        expect(body['mismatches']['1']).to be true   # wrong
        expect(body['mismatches']['2']).to be false  # empty space — not flagged
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
           headers: json_headers

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body['mismatches']['0']).to be false
    end
  end

  # ---------------------------------------------------------------------------
  # POST /crosswords/:id/check_cell — team mode
  # ---------------------------------------------------------------------------
  describe 'POST /crosswords/:id/check_cell (team)' do
    let(:owner)         { create(:user, :with_test_password) }
    let(:team_solution) { create(:solution, :team, user: owner, crossword: crossword, letters: blank_letters) }

    before do
      SolutionPartnering.create!(user: user, solution: team_solution)
      log_in_as(user)
    end

    it 'checks cells against the crossword answer (not the team solution)' do
      post "/crosswords/#{crossword.id}/check_cell",
           params: { letters: ['A'], indices: ['0'] },
           headers: json_headers

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body['mismatches']['0']).to be false
    end

    it 'detects incorrect letters in team mode' do
      post "/crosswords/#{crossword.id}/check_cell",
           params: { letters: ['Z'], indices: ['0'] },
           headers: json_headers

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body['mismatches']['0']).to be true
    end

    it 'handles full puzzle check in team mode' do
      post "/crosswords/#{crossword.id}/check_cell",
           params: { letters: correct_letters },
           headers: json_headers

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body['mismatches'].values).to all(be false)
    end
  end

  # ---------------------------------------------------------------------------
  # POST /crosswords/:id/check_cell — legacy JS fallback
  # ---------------------------------------------------------------------------
  describe 'POST /crosswords/:id/check_cell (JS legacy fallback)' do
    before { log_in_as(user) }

    it 'returns JavaScript with mismatch assignments' do
      post "/crosswords/#{crossword.id}/check_cell",
           params: { letters: ['A'], indices: ['0'] },
           headers: js_headers

      expect(response).to have_http_status(:ok)
      expect(response.media_type).to eq 'text/javascript'
      expect(response.body).to include('mismatches[0] = false')
    end
  end

  # ---------------------------------------------------------------------------
  # POST /crosswords/:id/check_completion — solo mode (JSON)
  # ---------------------------------------------------------------------------
  describe 'POST /crosswords/:id/check_completion (solo)' do
    let!(:solution) { create(:solution, user: user, crossword: crossword, letters: blank_letters) }

    before { log_in_as(user) }

    context 'with correct solution' do
      it 'returns JSON with correct: true and win modal HTML' do
        post "/crosswords/#{crossword.id}/check_completion",
             params: { letters: correct_letters, solution_id: solution.id },
             headers: json_headers

        expect(response).to have_http_status(:ok)
        body = JSON.parse(response.body)
        expect(body['correct']).to be true
        expect(body['win_modal_html']).to include('SOLVED!')
      end
    end

    context 'with incorrect solution' do
      it 'returns JSON with correct: false' do
        wrong = correct_letters.dup
        wrong[0] = 'Z'

        post "/crosswords/#{crossword.id}/check_completion",
             params: { letters: wrong, solution_id: solution.id },
             headers: json_headers

        expect(response).to have_http_status(:ok)
        body = JSON.parse(response.body)
        expect(body['correct']).to be false
        expect(body).not_to have_key('win_modal_html')
      end
    end

    context 'with partially filled solution (spaces remain)' do
      it 'returns incorrect since spaces do not match letters' do
        post "/crosswords/#{crossword.id}/check_completion",
             params: { letters: blank_letters, solution_id: solution.id },
             headers: json_headers

        expect(response).to have_http_status(:ok)
        body = JSON.parse(response.body)
        expect(body['correct']).to be false
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
           headers: json_headers

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body['correct']).to be true
    end

    it 'detects incorrect solution for anonymous users' do
      post "/crosswords/#{crossword.id}/check_completion",
           params: { letters: 'Z' * correct_letters.length },
           headers: json_headers

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body['correct']).to be false
    end
  end

  # ---------------------------------------------------------------------------
  # POST /crosswords/:id/check_completion — team mode
  # ---------------------------------------------------------------------------
  describe 'POST /crosswords/:id/check_completion (team)' do
    let(:owner)         { create(:user, :with_test_password) }
    let(:team_solution) { create(:solution, :team, user: owner, crossword: crossword, letters: blank_letters) }

    before do
      SolutionPartnering.create!(user: user, solution: team_solution)
      log_in_as(user)
    end

    it 'returns correct: true when team solution letters are all correct' do
      post "/crosswords/#{crossword.id}/check_completion",
           params: { letters: correct_letters, solution_id: team_solution.id },
           headers: json_headers

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body['correct']).to be true
      expect(body['win_modal_html']).to include('SOLVED!')
    end

    it 'returns correct: false when team solution has incorrect letters' do
      wrong = correct_letters.dup
      wrong[0] = 'Z'

      post "/crosswords/#{crossword.id}/check_completion",
           params: { letters: wrong, solution_id: team_solution.id },
           headers: json_headers

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body['correct']).to be false
    end
  end

  # ---------------------------------------------------------------------------
  # POST /crosswords/:id/check_completion — legacy JS fallback
  # ---------------------------------------------------------------------------
  describe 'POST /crosswords/:id/check_completion (JS legacy fallback)' do
    let!(:solution) { create(:solution, user: user, crossword: crossword, letters: blank_letters) }

    before { log_in_as(user) }

    it 'returns JavaScript that shows the win modal when correct' do
      post "/crosswords/#{crossword.id}/check_completion",
           params: { letters: correct_letters, solution_id: solution.id },
           headers: js_headers

      expect(response).to have_http_status(:ok)
      expect(response.media_type).to eq 'text/javascript'
      expect(response.body).to include('showModal()')
    end

    it 'returns JavaScript that shows an alert when incorrect' do
      wrong = correct_letters.dup
      wrong[0] = 'Z'

      post "/crosswords/#{crossword.id}/check_completion",
           params: { letters: wrong, solution_id: solution.id },
           headers: js_headers

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('incorrect letters')
    end
  end
end
