describe CrosswordsController do
  let(:user)      { create(:user) }
  let(:crossword) { create(:crossword, :smaller) }

  describe 'before_actions' do
    it { is_expected.to use_before_action(:ensure_logged_in) }
  end

  describe 'GET #show' do
    context 'anonymous' do
      before { get :show, params: { id: crossword.id } }
      it { is_expected.to respond_with(200) }
    end

    context 'logged in' do
      before { log_in(user); get :show, params: { id: crossword.id } }

      it { is_expected.to respond_with(200) }
      it 'creates a solution for the user' do
        expect(Solution.find_by(user: user, crossword: crossword)).to be_present
      end
    end

    context 'when crossword creator has been deleted (nil user_id)' do
      render_views

      before do
        crossword.update_column(:user_id, nil)
        get :show, params: { id: crossword.id }
      end

      it { is_expected.to respond_with(200) }
    end

    context 'with comments from deleted users' do
      render_views

      before do
        comment = Comment.create!(content: 'Test comment', user: user, crossword: crossword)
        comment.update_column(:user_id, nil)
        get :show, params: { id: crossword.id }
      end

      it { is_expected.to respond_with(200) }
    end
  end

  # check_cell and check_completion specs moved to spec/requests/check_functions_spec.rb
  # (POST request specs with proper HTTP method and response assertions)

  describe 'POST #create_team' do
    context 'when crossword does not exist' do
      before { log_in(user) }

      it 'redirects to root with error' do
        post :create_team, params: { id: 0 }
        expect(response).to redirect_to(root_path)
      end
    end

    context 'logged in' do
      before { log_in(user) }

      it 'creates a team solution and redirects to team path' do
        expect {
          post :create_team, params: { id: crossword.id }
        }.to change(Solution, :count).by(1)

        solution = Solution.last
        expect(solution.team).to be true
        expect(solution.key).to be_present
        expect(response).to redirect_to(team_crossword_path(crossword, solution.key))
      end
    end

    context 'anonymous' do
      it 'redirects to login' do
        post :create_team, params: { id: crossword.id }
        expect(response.location).to start_with("http://test.host#{account_required_path}")
      end
    end
  end

  describe 'GET #team' do
    let(:solution) { create(:solution, :team, user: user, crossword: crossword) }

    context 'valid team key' do
      before { log_in(user); get :team, params: { id: crossword.id, key: solution.key } }

      it { is_expected.to respond_with(200) }

      it 'assigns @comments' do
        expect(assigns(:comments)).not_to be_nil
      end

      it 'assigns @cells' do
        expect(assigns(:cells)).to be_present
      end

      it 'sets @team to true' do
        expect(assigns(:team)).to be true
      end
    end

    context 'anonymous visitor with valid key' do
      before { get :team, params: { id: crossword.id, key: solution.key } }

      it { is_expected.to respond_with(200) }

      it 'assigns @comments' do
        expect(assigns(:comments)).not_to be_nil
      end
    end

    context 'invalid team key' do
      before { log_in(user); get :team, params: { id: crossword.id, key: 'bogus' } }

      it 'redirects to root' do
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe 'POST #favorite' do
    before do
      request.accept = Mime[:turbo_stream].to_s
      log_in(user)
    end

    it 'creates a FavoritePuzzle record' do
      expect {
        post :favorite, params: { id: crossword.id }
      }.to change(FavoritePuzzle, :count).by(1)
    end

    it 'does not duplicate an existing favorite' do
      FavoritePuzzle.create!(user: user, crossword: crossword)
      expect {
        post :favorite, params: { id: crossword.id }
      }.not_to change(FavoritePuzzle, :count)
    end
  end

  describe 'DELETE #unfavorite' do
    before do
      request.accept = Mime[:turbo_stream].to_s
      log_in(user)
      FavoritePuzzle.create!(user: user, crossword: crossword)
    end

    it 'destroys the FavoritePuzzle record' do
      expect {
        delete :unfavorite, params: { id: crossword.id }
      }.to change(FavoritePuzzle, :count).by(-1)
    end
  end
end