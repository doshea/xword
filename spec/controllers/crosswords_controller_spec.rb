describe CrosswordsController do
  let(:user)      { create(:user) }
  let(:crossword) { create(:crossword, :smaller) }

  def log_in(u)
    session[:user_id] = u.id
  end

  describe 'before_actions' do
    it { should use_before_action(:ensure_owner_or_admin) }
  end

  describe 'GET #show' do
    context 'anonymous' do
      before { get :show, params: { id: crossword.id } }
      it { should respond_with(200) }
    end

    context 'logged in' do
      before { log_in(user); get :show, params: { id: crossword.id } }

      it { should respond_with(200) }
      it 'creates a solution for the user' do
        expect(Solution.find_by(user: user, crossword: crossword)).to be_present
      end
    end
  end

  describe 'GET #batch' do
    # batch renders batch.turbo_stream.erb (lazy-load of crossword tabs)
    before do
      request.accept = Mime[:turbo_stream].to_s
      get :batch, params: { ids: [crossword.id] }
    end
    it { should respond_with(200) }
  end

  describe 'GET #check_cell' do
    # check_cell renders check_cell.js.erb via $.ajax(dataType:'script') — mark as XHR to bypass cross-origin check
    before do
      request.env["HTTP_X_REQUESTED_WITH"] = "XMLHttpRequest"
      get :check_cell,
          params: { id: crossword.id, letters: crossword.letters },
          format: :js
    end

    it { should respond_with(200) }
    it 'assigns @mismatches' do
      expect(assigns(:mismatches)).to be_present
    end
  end

  describe 'GET #check_completion' do
    # check_completion renders check_completion.js.erb via $.ajax(dataType:'script') — mark as XHR
    context 'correct solution' do
      before do
        request.env["HTTP_X_REQUESTED_WITH"] = "XMLHttpRequest"
        get :check_completion,
            params: { id: crossword.id, letters: crossword.letters },
            format: :js
      end
      it 'assigns @correctness as true' do
        expect(assigns(:correctness)).to be true
      end
    end

    context 'incorrect solution' do
      before do
        request.env["HTTP_X_REQUESTED_WITH"] = "XMLHttpRequest"
        # Use non-space characters — crossword.letters is all spaces, so 'X' * n != ' ' * n
        wrong_letters = 'X' * crossword.letters.length
        get :check_completion,
            params: { id: crossword.id, letters: wrong_letters },
            format: :js
      end
      it 'assigns @correctness as false' do
        expect(assigns(:correctness)).to be false
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