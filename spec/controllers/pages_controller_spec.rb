describe PagesController do
  context 'anonymous' do
    context 'GET #home' do
      before { get :home }

      it { should respond_with(:success) }
    end
  end

  context 'logged_in' do
    before { get :home }
    it { should respond_with(:success) }
  end

  # ---------------------------------------------------------------------------
  # GET #live_search
  # ---------------------------------------------------------------------------
  describe 'GET #live_search' do
    before do
      request.env["HTTP_X_REQUESTED_WITH"] = "XMLHttpRequest"
    end

    context 'with JSON format (current client)' do
      let!(:user)      { create(:user, username: 'puzzlemaker') }
      let!(:crossword) { create(:crossword) }
      let!(:word)      { Word.create!(content: 'PUZZLE') }

      it 'returns result_count and html when matches exist' do
        get :live_search, params: { query: 'puzzle' }, format: :json
        expect(response).to have_http_status(:ok)
        body = JSON.parse(response.body)
        expect(body['result_count']).to be >= 1
        expect(body['html']).to be_present
      end

      it 'returns zero result_count with no html when no matches' do
        get :live_search, params: { query: 'zzzznotfound' }, format: :json
        expect(response).to have_http_status(:ok)
        body = JSON.parse(response.body)
        expect(body['result_count']).to eq 0
        expect(body).not_to have_key('html')
      end

      it 'handles blank query' do
        get :live_search, params: { query: '' }, format: :json
        expect(response).to have_http_status(:ok)
        body = JSON.parse(response.body)
        expect(body['result_count']).to eq 0
      end
    end

    context 'with JS format (legacy fallback)' do
      let!(:crossword) { create(:crossword) }

      it 'returns JavaScript response' do
        get :live_search, params: { query: crossword.title[0..4] }, format: :js
        expect(response).to have_http_status(:ok)
      end
    end
  end

  # ---------------------------------------------------------------------------
  # GET #search (HTML)
  # ---------------------------------------------------------------------------
  describe 'GET #search' do
    before { get :search, params: { query: 'test' } }

    it { should respond_with(200) }
    it 'assigns @query' do
      expect(assigns(:query)).to eq 'test'
    end
  end

  # ---------------------------------------------------------------------------
  # Nil-safety: nytimes user missing
  # ---------------------------------------------------------------------------
  describe 'GET #nytimes' do
    context 'when nytimes user does not exist' do
      before { get :nytimes }
      it { should respond_with(200) }
    end
  end

  describe 'GET #user_made' do
    context 'when nytimes user does not exist' do
      before { get :user_made }
      it { should respond_with(200) }
    end
  end
end
