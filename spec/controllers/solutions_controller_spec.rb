describe SolutionsController do
  let(:user)      { create(:user) }
  let(:crossword) { create(:crossword, :smaller) }
  let(:solution)  { create(:solution, user: user, crossword: crossword) }

  context 'before_actions' do
    it { should use_before_action(:ensure_owner_or_partner) }
  end

  describe 'GET #show' do
    context 'non-team solution' do
      # show redirects to the associated crossword (not a team solution)
      before { get :show, params: { id: solution.id } }
      it { should redirect_to(crossword) }
    end

    context 'when crossword has been deleted (nil crossword_id)' do
      before do
        solution.update_column(:crossword_id, nil)
        get :show, params: { id: solution.id }
      end

      it 'redirects to root with alert' do
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq "This puzzle is no longer available."
      end
    end
  end

  describe 'PATCH #update' do
    # update.js.erb is called via $.ajax from solve_funcs.js (format.js, not Turbo)
    before do
      log_in(user)
      patch :update, params: { id: solution.id, letters: 'ABCDE', save_counter: '0.12345' }, format: :js
    end

    it { should respond_with(200) }
    it 'updates the solution letters' do
      expect(solution.reload.letters).to eq 'ABCDE'
    end
    it 'passes save_counter through to the response template' do
      expect(assigns(:save_counter)).to eq '0.12345'
    end

    context 'with a null/invalid id (stale JS sending solution_id before it was set)' do
      # guard_null_solution_id runs before find_object to absorb these silently without
      # setting a flash error that would persist and show up on subsequent pages
      it 'returns 200 and sets no flash' do
        patch :update, params: { id: 'null', letters: 'X' }, format: :js
        expect(response).to have_http_status(200)
        expect(flash[:error]).to be_nil
      end
    end
  end

  describe 'PATCH #team_update' do
    let(:team_solution) { create(:solution, :team, user: user, crossword: crossword) }

    context 'when logged in' do
      before { log_in(user) }

      it 'broadcasts change_cell via ActionCable and returns 200' do
        expect(ActionCable.server).to receive(:broadcast)
          .with("team_#{team_solution.key}", hash_including(event: 'change_cell'))
        patch :team_update, params: {
          id: team_solution.id, row: '0', col: '1', letter: 'A',
          solver_id: 'abc', red: '100', green: '200', blue: '50'
        }
        expect(response).to have_http_status(:ok)
      end
    end

    context 'when not logged in' do
      it 'redirects to login' do
        patch :team_update, params: { id: team_solution.id, row: '0', col: '1', letter: 'A', solver_id: 'abc' }
        expect(response).to redirect_to(account_required_path)
      end
    end
  end

  describe 'POST #join_team' do
    let(:team_solution) { create(:solution, :team, user: user, crossword: crossword) }

    before { log_in(user) }

    it 'broadcasts join_puzzle via ActionCable' do
      expect(ActionCable.server).to receive(:broadcast)
        .with("team_#{team_solution.key}", hash_including(event: 'join_puzzle'))
      post :join_team, params: {
        id: team_solution.id, display_name: 'Dylan', solver_id: 'abc',
        red: '100', green: '200', blue: '50'
      }
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'POST #leave_team' do
    let(:team_solution) { create(:solution, :team, user: user, crossword: crossword) }

    before { log_in(user) }

    it 'broadcasts leave_puzzle via ActionCable' do
      expect(ActionCable.server).to receive(:broadcast)
        .with("team_#{team_solution.key}", hash_including(event: 'leave_puzzle'))
      post :leave_team, params: { id: team_solution.id, solver_id: 'abc' }
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'POST #roll_call' do
    let(:team_solution) { create(:solution, :team, user: user, crossword: crossword) }

    before { log_in(user) }

    it 'broadcasts roll_call via ActionCable' do
      expect(ActionCable.server).to receive(:broadcast)
        .with("team_#{team_solution.key}", hash_including(event: 'roll_call'))
      post :roll_call, params: { id: team_solution.id }
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'POST #send_team_chat' do
    let(:team_solution) { create(:solution, :team, user: user, crossword: crossword) }

    before do
      log_in(user)
      request.accept = Mime[:turbo_stream].to_s
    end

    it 'broadcasts chat_message via ActionCable' do
      expect(ActionCable.server).to receive(:broadcast)
        .with("team_#{team_solution.key}", hash_including(event: 'chat_message'))
      post :send_team_chat, params: {
        id: team_solution.id, display_name: 'Dylan',
        avatar: '/default.jpg', chat: 'Hello team!'
      }
      expect(response).to have_http_status(:ok)
    end

    it 'returns success even when Redis is unavailable' do
      allow(ActionCable.server).to receive(:broadcast)
        .and_raise(Redis::CannotConnectError)
      post :send_team_chat, params: {
        id: team_solution.id, display_name: 'Dylan',
        avatar: '/default.jpg', chat: 'Hello team!'
      }
      expect(response).to have_http_status(:ok)
    end

    context 'when Redis is unavailable' do
      render_views

      it 'includes an error notice in the turbo_stream response' do
        allow(ActionCable.server).to receive(:broadcast)
          .and_raise(Redis::CannotConnectError)
        post :send_team_chat, params: {
          id: team_solution.id, display_name: 'Dylan',
          avatar: '/default.jpg', chat: 'Hello team!'
        }
        expect(response.body).to include('team-chat-error')
      end
    end
  end

  describe 'POST #roll_call (Redis unavailable)' do
    let(:team_solution) { create(:solution, :team, user: user, crossword: crossword) }

    before { log_in(user) }

    it 'returns success even when Redis is unavailable' do
      allow(ActionCable.server).to receive(:broadcast)
        .and_raise(Redis::CannotConnectError)
      post :roll_call, params: { id: team_solution.id }
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'PATCH #team_update (Redis unavailable)' do
    let(:team_solution) { create(:solution, :team, user: user, crossword: crossword) }

    before { log_in(user) }

    it 'returns success even when Redis is unavailable' do
      allow(ActionCable.server).to receive(:broadcast)
        .and_raise(Redis::CannotConnectError)
      patch :team_update, params: {
        id: team_solution.id, row: '0', col: '1', letter: 'A',
        solver_id: 'abc', red: '100', green: '200', blue: '50'
      }
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'POST #show_team_clue' do
    let(:team_solution) { create(:solution, :team, user: user, crossword: crossword) }

    before { log_in(user) }

    it 'broadcasts outline_team_clue via ActionCable' do
      expect(ActionCable.server).to receive(:broadcast)
        .with("team_#{team_solution.key}", hash_including(event: 'outline_team_clue'))
      post :show_team_clue, params: {
        id: team_solution.id, cell_num: '1', across: 'true',
        solver_id: 'abc', red: '100', green: '200', blue: '50'
      }
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'DELETE #destroy' do
    context 'as the solution owner' do
      before { log_in(user); solution }
      it 'destroys the solution' do
        expect {
          delete :destroy, params: { id: solution.id }
        }.to change(Solution, :count).by(-1)
      end
      it { delete :destroy, params: { id: solution.id }; should redirect_to(:root) }
    end

    context 'as an unrelated user' do
      let(:other) { create(:user) }
      before { log_in(other); solution }
      it 'does not destroy the solution' do
        expect {
          delete :destroy, params: { id: solution.id }
        }.not_to change(Solution, :count)
      end
    end
  end
end
