RSpec.describe 'Solutions', type: :request do
  let(:test_password) { 'password123' }
  let(:user)      { create(:user, password: test_password, password_confirmation: test_password) }
  let(:crossword) { create(:predefined_five_by_five) }
  # 5x5 grid, correct letters = 'AMIGOVOLOWANIONIDOSELONER'
  let(:correct_letters) { crossword.letters }
  let(:blank_letters)   { correct_letters.gsub(/[^_]/, ' ') }
  let(:solution)  { create(:solution, user: user, crossword: crossword, letters: blank_letters) }

  def log_in_as(u)
    post '/login', params: { username: u.username, password: test_password }
  end

  # -------------------------------------------------------------------------
  # Solo solve — saving letters
  # -------------------------------------------------------------------------
  describe 'PUT /solutions/:id (solo save)' do
    before { log_in_as(user) }

    it 'persists the submitted letters to the database' do
      partial = blank_letters.dup
      partial[0] = 'A'   # fill first cell
      partial[1] = 'M'

      put "/solutions/#{solution.id}", params: { letters: partial, save_counter: '0.1' }, headers: { 'Accept' => 'text/javascript', 'X-Requested-With' => 'XMLHttpRequest' }
      expect(response).to have_http_status(:ok)
      expect(solution.reload.letters[0..1]).to eq 'AM'
    end

    it 'preserves the full letter string across multiple saves' do
      first_save = blank_letters.dup
      first_save[0] = 'A'
      put "/solutions/#{solution.id}", params: { letters: first_save, save_counter: '0.1' }, headers: { 'Accept' => 'text/javascript', 'X-Requested-With' => 'XMLHttpRequest' }

      second_save = solution.reload.letters.dup
      second_save[5] = 'V'
      put "/solutions/#{solution.id}", params: { letters: second_save, save_counter: '0.2' }, headers: { 'Accept' => 'text/javascript', 'X-Requested-With' => 'XMLHttpRequest' }

      result = solution.reload.letters
      expect(result[0]).to eq 'A'
      expect(result[5]).to eq 'V'
    end

    it 'marks the solution complete when all letters are correct' do
      put "/solutions/#{solution.id}", params: { letters: correct_letters, save_counter: '0.1' }, headers: { 'Accept' => 'text/javascript', 'X-Requested-With' => 'XMLHttpRequest' }

      solution.reload
      expect(solution.is_complete).to be true
      expect(solution.solved_at).to be_present
    end

    it 'leaves the solution incomplete when letters are wrong' do
      wrong = correct_letters.dup
      wrong[0] = 'Z'
      put "/solutions/#{solution.id}", params: { letters: wrong, save_counter: '0.1' }, headers: { 'Accept' => 'text/javascript', 'X-Requested-With' => 'XMLHttpRequest' }

      expect(solution.reload.is_complete).to be false
    end

    it 'silently handles a null solution id from stale JS' do
      put "/solutions/null", params: { letters: 'X' }, headers: { 'Accept' => 'text/javascript', 'X-Requested-With' => 'XMLHttpRequest' }
      expect(response).to have_http_status(:ok)
    end
  end

  # -------------------------------------------------------------------------
  # Team solve — broadcasting cell changes
  # -------------------------------------------------------------------------
  describe 'PATCH /solutions/:id/team_update (team cell broadcast)' do
    let(:team_solution) { create(:solution, :team, user: user, crossword: crossword, letters: blank_letters) }

    before { log_in_as(user) }

    it 'broadcasts a change_cell event with the correct payload' do
      expect(ActionCable.server).to receive(:broadcast)
        .with("team_#{team_solution.key}", hash_including(
          event: 'change_cell',
          row: '3', col: '2', letter: 'A', solver_id: 'solver1',
          server_time: a_kind_of(Integer)
        ))

      patch "/solutions/#{team_solution.id}/team_update", params: {
        row: '3', col: '2', letter: 'A',
        solver_id: 'solver1', red: '100', green: '150', blue: '50'
      }
      expect(response).to have_http_status(:ok)
    end

    it 'includes solver color in the broadcast' do
      expect(ActionCable.server).to receive(:broadcast)
        .with("team_#{team_solution.key}", hash_including(
          red: '255', green: '0', blue: '128',
          server_time: a_kind_of(Integer)
        ))

      patch "/solutions/#{team_solution.id}/team_update", params: {
        row: '1', col: '1', letter: 'X',
        solver_id: 'abc', red: '255', green: '0', blue: '128'
      }
    end

    it 'broadcasts a delete (empty letter) when a cell is cleared' do
      expect(ActionCable.server).to receive(:broadcast)
        .with("team_#{team_solution.key}", hash_including(
          event: 'change_cell', letter: '',
          server_time: a_kind_of(Integer)
        ))

      patch "/solutions/#{team_solution.id}/team_update", params: {
        row: '1', col: '1', letter: '',
        solver_id: 'solver1', red: '0', green: '0', blue: '0'
      }
    end

    it 'returns 200 even when Redis is unavailable' do
      allow(ActionCable.server).to receive(:broadcast)
        .and_raise(Redis::CannotConnectError)

      patch "/solutions/#{team_solution.id}/team_update", params: {
        row: '1', col: '1', letter: 'A',
        solver_id: 'solver1', red: '0', green: '0', blue: '0'
      }
      expect(response).to have_http_status(:ok)
    end

    it 'requires authentication' do
      # Fresh request without logging in
      reset!
      patch "/solutions/#{team_solution.id}/team_update", params: {
        row: '1', col: '1', letter: 'A', solver_id: 'x'
      }
      expect(response).to redirect_to(account_required_path)
    end
  end

  # -------------------------------------------------------------------------
  # Team solve — two users sending interleaved edits
  # -------------------------------------------------------------------------
  describe 'two users editing a team puzzle' do
    let(:user_b)        { create(:user, password: test_password, password_confirmation: test_password) }
    let(:team_solution) { create(:solution, :team, user: user, crossword: crossword, letters: blank_letters) }
    let(:channel)       { "team_#{team_solution.key}" }

    before { SolutionPartnering.create!(user: user_b, solution: team_solution) }

    it 'broadcasts each user\'s cell changes independently' do
      broadcasts = []
      allow(ActionCable.server).to receive(:broadcast) do |ch, payload|
        broadcasts << payload if ch == channel
      end

      # User A types 'A' at (1,1)
      log_in_as(user)
      patch "/solutions/#{team_solution.id}/team_update", params: {
        row: '1', col: '1', letter: 'A',
        solver_id: 'solverA', red: '200', green: '0', blue: '0'
      }

      # User B types 'V' at (2,1)
      log_in_as(user_b)
      patch "/solutions/#{team_solution.id}/team_update", params: {
        row: '2', col: '1', letter: 'V',
        solver_id: 'solverB', red: '0', green: '0', blue: '200'
      }

      # User A types 'M' at (1,2)
      log_in_as(user)
      patch "/solutions/#{team_solution.id}/team_update", params: {
        row: '1', col: '2', letter: 'M',
        solver_id: 'solverA', red: '200', green: '0', blue: '0'
      }

      expect(broadcasts.length).to eq 3
      expect(broadcasts[0]).to include(solver_id: 'solverA', letter: 'A', row: '1', col: '1')
      expect(broadcasts[1]).to include(solver_id: 'solverB', letter: 'V', row: '2', col: '1')
      expect(broadcasts[2]).to include(solver_id: 'solverA', letter: 'M', row: '1', col: '2')

      timestamps = broadcasts.map { |b| b[:server_time] }
      timestamps.each { |t| expect(t).to be_a(Integer) }
      expect(timestamps).to eq(timestamps.sort)
    end

    it 'includes monotonically non-decreasing server_time across successive broadcasts' do
      broadcasts = []
      allow(ActionCable.server).to receive(:broadcast) do |ch, payload|
        broadcasts << payload if ch == channel
      end

      log_in_as(user)
      5.times do |i|
        patch "/solutions/#{team_solution.id}/team_update", params: {
          row: '0', col: i.to_s, letter: ('A'.ord + i).chr,
          solver_id: 'solverA', red: '0', green: '0', blue: '0'
        }
      end

      timestamps = broadcasts.map { |b| b[:server_time] }
      expect(timestamps.length).to eq 5
      timestamps.each { |t| expect(t).to be_a(Integer).and be > 0 }
      timestamps.each_cons(2) { |a, b| expect(b).to be >= a }
    end

    it 'saves the team solution when either user triggers a full save' do
      log_in_as(user)
      partial = blank_letters.dup
      partial[0] = 'A'
      partial[5] = 'V'

      put "/solutions/#{team_solution.id}", params: { letters: partial, save_counter: '0.1' }, headers: { 'Accept' => 'text/javascript', 'X-Requested-With' => 'XMLHttpRequest' }
      expect(team_solution.reload.letters[0]).to eq 'A'
      expect(team_solution.reload.letters[5]).to eq 'V'
    end

    it 'marks the team solution complete when saved with correct letters' do
      log_in_as(user)
      put "/solutions/#{team_solution.id}", params: { letters: correct_letters, save_counter: '0.1' }, headers: { 'Accept' => 'text/javascript', 'X-Requested-With' => 'XMLHttpRequest' }

      team_solution.reload
      expect(team_solution.is_complete).to be true
      expect(team_solution.solved_at).to be_present
    end
  end

  # -------------------------------------------------------------------------
  # GET /solutions/:id — show (routing logic)
  # -------------------------------------------------------------------------
  describe 'GET /solutions/:id (show routing)' do
    context 'solo solution redirects to crossword' do
      it 'redirects to the crossword page' do
        get "/solutions/#{solution.id}"
        expect(response).to redirect_to(crossword_path(crossword))
      end
    end

    context 'team solution as the owner' do
      let(:team_solution) { create(:solution, :team, user: user, crossword: crossword, letters: blank_letters) }

      before { log_in_as(user) }

      it 'redirects to the team crossword page' do
        get "/solutions/#{team_solution.id}"
        expect(response).to redirect_to(team_crossword_path(crossword, team_solution.key))
      end
    end

    context 'team solution as a partner' do
      let(:owner) { create(:user, password: test_password, password_confirmation: test_password) }
      let(:team_solution) { create(:solution, :team, user: owner, crossword: crossword, letters: blank_letters) }

      before do
        SolutionPartnering.create!(user: user, solution: team_solution)
        log_in_as(user)
      end

      it 'redirects to the team crossword page' do
        get "/solutions/#{team_solution.id}"
        expect(response).to redirect_to(team_crossword_path(crossword, team_solution.key))
      end
    end

    context 'team solution as an unrelated user' do
      let(:owner) { create(:user, password: test_password, password_confirmation: test_password) }
      let(:team_solution) { create(:solution, :team, user: owner, crossword: crossword, letters: blank_letters) }

      before { log_in_as(user) }

      it 'returns 403 forbidden' do
        get "/solutions/#{team_solution.id}"
        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'orphaned solution (crossword deleted)' do
      before { solution.update_column(:crossword_id, nil) }

      it 'redirects to root with an alert' do
        get "/solutions/#{solution.id}"
        expect(response).to redirect_to(root_path)
      end
    end
  end

  # -------------------------------------------------------------------------
  # POST /solutions/:id/get_incorrect
  # -------------------------------------------------------------------------
  describe 'POST /solutions/:id/get_incorrect' do
    it 'returns 200 with correct letters (no mismatches)' do
      post "/solutions/#{solution.id}/get_incorrect", params: { letters: correct_letters }
      expect(response).to have_http_status(:ok)
    end

    it 'marks the solution complete when all letters match' do
      post "/solutions/#{solution.id}/get_incorrect", params: { letters: correct_letters }
      expect(solution.reload.is_complete).to be true
    end

    it 'does not mark solution complete when there are mismatches' do
      wrong = correct_letters.dup
      wrong[0] = 'Z'
      post "/solutions/#{solution.id}/get_incorrect", params: { letters: wrong }
      expect(solution.reload.is_complete).to be false
    end

    it 'returns 404 for an orphaned solution (crossword deleted)' do
      solution.update_column(:crossword_id, nil)
      post "/solutions/#{solution.id}/get_incorrect", params: { letters: 'ABC' }
      expect(response).to have_http_status(:not_found)
    end
  end

  # -------------------------------------------------------------------------
  # Team action authorization — only owner and partners may call team actions
  # -------------------------------------------------------------------------
  describe 'team action authorization' do
    let(:owner)         { create(:user, password: test_password, password_confirmation: test_password) }
    let(:partner)       { user }  # reuse `user` let as the partner
    let(:outsider)      { create(:user, password: test_password, password_confirmation: test_password) }
    let(:team_solution) { create(:solution, :team, user: owner, crossword: crossword, letters: blank_letters) }

    before do
      SolutionPartnering.create!(user: partner, solution: team_solution)
      allow(ActionCable.server).to receive(:broadcast)
    end

    context 'as a non-member (not owner or partner)' do
      before { log_in_as(outsider) }

      it 'rejects team_update with 403' do
        patch "/solutions/#{team_solution.id}/team_update",
              params: { row: '0', col: '0', letter: 'A', solver_id: 'x', red: '0', green: '0', blue: '0' }
        expect(response).to have_http_status(:forbidden)
      end

      it 'rejects join_team with 403' do
        post "/solutions/#{team_solution.id}/join_team",
             params: { display_name: 'Test', solver_id: 'x', red: '0', green: '0', blue: '0' }
        expect(response).to have_http_status(:forbidden)
      end

      it 'rejects leave_team with 403' do
        post "/solutions/#{team_solution.id}/leave_team",
             params: { solver_id: 'x' }
        expect(response).to have_http_status(:forbidden)
      end

      it 'rejects roll_call with 403' do
        post "/solutions/#{team_solution.id}/roll_call"
        expect(response).to have_http_status(:forbidden)
      end

      it 'rejects send_team_chat with 403' do
        post "/solutions/#{team_solution.id}/send_team_chat",
             params: { display_name: 'Test', avatar: '/default.jpg', chat: 'hello' }
        expect(response).to have_http_status(:forbidden)
      end

      it 'rejects show_team_clue with 403' do
        post "/solutions/#{team_solution.id}/show_team_clue",
             params: { cell_num: '1', across: 'true', solver_id: 'x', red: '0', green: '0', blue: '0' }
        expect(response).to have_http_status(:forbidden)
      end

      it 'does not broadcast when rejected' do
        patch "/solutions/#{team_solution.id}/team_update",
              params: { row: '0', col: '0', letter: 'A', solver_id: 'x', red: '0', green: '0', blue: '0' }
        expect(ActionCable.server).not_to have_received(:broadcast)
      end
    end

    context 'as a team partner (not owner)' do
      before { log_in_as(partner) }

      it 'allows team_update' do
        patch "/solutions/#{team_solution.id}/team_update",
              params: { row: '0', col: '0', letter: 'A', solver_id: 'x', red: '0', green: '0', blue: '0' }
        expect(response).to have_http_status(:ok)
      end

      it 'allows join_team' do
        post "/solutions/#{team_solution.id}/join_team",
             params: { display_name: 'Test', solver_id: 'x', red: '0', green: '0', blue: '0' }
        expect(response).to have_http_status(:ok)
      end

      it 'allows leave_team' do
        post "/solutions/#{team_solution.id}/leave_team",
             params: { solver_id: 'x' }
        expect(response).to have_http_status(:ok)
      end

      it 'allows roll_call' do
        post "/solutions/#{team_solution.id}/roll_call"
        expect(response).to have_http_status(:ok)
      end

      it 'allows send_team_chat' do
        post "/solutions/#{team_solution.id}/send_team_chat",
             params: { display_name: 'Test', avatar: '/default.jpg', chat: 'hello' },
             headers: { 'Accept' => Mime[:turbo_stream].to_s }
        expect(response).to have_http_status(:ok)
      end

      it 'allows show_team_clue' do
        post "/solutions/#{team_solution.id}/show_team_clue",
             params: { cell_num: '1', across: 'true', solver_id: 'x', red: '0', green: '0', blue: '0' }
        expect(response).to have_http_status(:ok)
      end
    end
  end

  # -------------------------------------------------------------------------
  # DELETE /solutions/:id — destroy
  # -------------------------------------------------------------------------
  describe 'DELETE /solutions/:id (destroy)' do
    context 'as a partner (not owner)' do
      let(:owner) { create(:user, password: test_password, password_confirmation: test_password) }
      let(:team_solution) { create(:solution, :team, user: owner, crossword: crossword, letters: blank_letters) }

      before do
        SolutionPartnering.create!(user: user, solution: team_solution)
        log_in_as(user)
      end

      it 'destroys the partnership, not the solution' do
        expect {
          delete "/solutions/#{team_solution.id}"
        }.to change(SolutionPartnering, :count).by(-1)
          .and change(Solution, :count).by(0)
      end
    end
  end
end
