describe PagesController do
  context 'anonymous' do
    context 'GET #home' do
      it 'redirects to welcome' do
        get :home
        expect(response).to redirect_to(welcome_path)
      end

      it 'renders when session[:browsing] is set' do
        session[:browsing] = true
        get :home
        expect(response).to have_http_status(:ok)
      end
    end
  end

  context 'logged_in' do
    let(:user) { create(:user) }
    before { log_in(user) }

    it 'responds successfully' do
      get :home
      expect(response).to have_http_status(:ok)
    end
  end

  # ---------------------------------------------------------------------------
  # GET #live_search
  # ---------------------------------------------------------------------------
  describe 'GET #live_search' do
    render_views

    before do
      request.env["HTTP_X_REQUESTED_WITH"] = "XMLHttpRequest"
    end

    context 'with JSON format (current client)' do
      # Use let! (not let_it_be) — pg_search full-text queries can't reliably see
      # let_it_be records due to transaction visibility + DatabaseCleaner interaction.
      let!(:search_user) { create(:user, username: 'puzzlemaker') }
      let!(:crossword)   { create(:crossword) }
      let!(:word)        { Word.create!(content: 'PUZZLE') }

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
      let_it_be(:crossword) { create(:crossword) }

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

    it 'responds successfully' do
      expect(response).to have_http_status(:ok)
    end

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

      it 'responds successfully' do
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe 'GET #user_made' do
    context 'when nytimes user does not exist' do
      before { get :user_made }

      it 'responds successfully' do
        expect(response).to have_http_status(:ok)
      end
    end
  end
end
