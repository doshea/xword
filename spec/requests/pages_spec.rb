RSpec.describe 'Pages', type: :request do
  let(:user)      { create(:user, :with_test_password) }

  # -------------------------------------------------------------------------
  # GET / — Home page scopes (Publishable concern)
  # -------------------------------------------------------------------------
  describe 'GET / (home)' do
    # Create another user to own the crosswords (so they're "unowned" from user's perspective)
    let(:creator) { create(:user) }

    context 'when logged in' do
      before { log_in_as(user) }

      it 'categorizes an incomplete solution as in-progress' do
        crossword = create(:crossword, :smaller, user: creator)
        blank = crossword.letters.gsub(/[^_]/, ' ')
        create(:solution, user: user, crossword: crossword, letters: blank)

        get '/'
        expect(response).to have_http_status(:ok)
      end

      it 'categorizes a complete solution as solved' do
        crossword = create(:crossword, :smaller, user: creator)
        create(:solution, :complete, user: user, crossword: crossword)

        get '/'
        expect(response).to have_http_status(:ok)
      end

      it 'categorizes a crossword with no solution as unstarted' do
        create(:crossword, :smaller, user: creator)

        get '/'
        expect(response).to have_http_status(:ok)
      end

      it 'includes team-partnered in-progress puzzles' do
        crossword = create(:crossword, :smaller, user: creator)
        owner = create(:user)
        blank = crossword.letters.gsub(/[^_]/, ' ')
        team_sol = create(:solution, :team, user: owner, crossword: crossword, letters: blank)
        SolutionPartnering.create!(user: user, solution: team_sol)

        get '/'
        expect(response).to have_http_status(:ok)
      end

      it 'includes team-partnered solved puzzles' do
        crossword = create(:crossword, :smaller, user: creator)
        owner = create(:user)
        team_sol = create(:solution, :complete, :team, user: owner, crossword: crossword)
        SolutionPartnering.create!(user: user, solution: team_sol)

        get '/'
        expect(response).to have_http_status(:ok)
      end
    end

    context 'when anonymous' do
      it 'redirects to the welcome page' do
        get '/'
        expect(response).to redirect_to(welcome_path)
      end

      it 'renders the home page after skipping welcome' do
        get '/skip_welcome'
        expect(response).to redirect_to(root_path)
        get '/'
        expect(response).to have_http_status(:ok)
      end
    end
  end

  # -------------------------------------------------------------------------
  # Static / simple pages — basic smoke tests
  # -------------------------------------------------------------------------
  describe 'GET /welcome' do
    it 'renders for anonymous users' do
      get '/welcome'
      expect(response).to have_http_status(:ok)
    end

    it 'redirects logged-in users to root' do
      log_in_as(user)
      get '/welcome'
      expect(response).to redirect_to(root_path)
    end
  end

  describe 'GET /error' do
    it 'renders the error page' do
      get '/error'
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'GET /unauthorized' do
    it 'renders the unauthorized page' do
      get '/unauthorized'
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'GET /account_required' do
    it 'renders the account required page' do
      get '/account_required'
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'GET /faq' do
    it 'renders the FAQ page' do
      get '/faq'
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'GET /about' do
    context 'as admin' do
      let(:admin) { create(:user, :with_test_password, is_admin: true) }
      before do
        log_in_as(admin)
        get '/about'
      end

      it 'renders the about page' do
        expect(response).to have_http_status(:ok)
      end

      it 'uses <s> for stylistic strikethrough, not <del>' do
        expect(response.body).to include('<s>')
        expect(response.body).not_to include('<del>')
      end

      it 'separates The Resurrection with a divider' do
        expect(response.body).to match(%r{<hr\s*/?>.*The Resurrection}m)
      end
    end

    context 'as non-admin' do
      it 'redirects to root' do
        get '/about'
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe 'GET /contact' do
    it 'renders the contact page' do
      get '/contact'
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'GET /stats' do
    it 'renders with users in the database' do
      create(:user) # ensure at least one user exists
      get '/stats'
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'GET /search' do
    it 'renders the search page with a query' do
      get '/search', params: { query: 'test' }
      expect(response).to have_http_status(:ok)
    end

    it 'renders the landing state with a blank query' do
      get '/search'
      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Site Search')
    end

    it 'shows empty state tips when no results match' do
      get '/search', params: { query: 'zzzznotfound' }
      expect(response).to have_http_status(:ok)
      expect(response.body).to include('No results found')
      expect(response.body).to include('xw-search-tips')
    end

    it 'renders word results as links to word detail pages' do
      word = Word.create!(content: 'OREO')
      get '/search', params: { query: 'OREO' }
      expect(response).to have_http_status(:ok)
      expect(response.body).to include(word_path(word))
    end
  end

  # -------------------------------------------------------------------------
  # GET /live_search — nav bar AJAX search
  # -------------------------------------------------------------------------
  describe 'GET /live_search' do
    let(:ajax_headers) { { 'Accept' => 'application/json', 'X-Requested-With' => 'XMLHttpRequest' } }

    it 'returns result_count and html when matches exist' do
      Word.create!(content: 'TESTING')
      get '/live_search', params: { query: 'TESTING' }, headers: ajax_headers
      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body['result_count']).to be >= 1
      expect(body['html']).to be_present
    end

    it 'returns zero result_count with no html when no matches' do
      get '/live_search', params: { query: 'zzzznotfound' }, headers: ajax_headers
      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body['result_count']).to eq 0
      expect(body).not_to have_key('html')
    end

    it 'handles blank query gracefully' do
      get '/live_search', params: { query: '' }, headers: ajax_headers
      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body['result_count']).to eq 0
    end

    it 'splits results evenly across categories' do
      user = create(:user, :with_test_password, username: 'searchterm')
      Word.create!(content: 'SEARCHTERM')
      get '/live_search', params: { query: 'searchterm' }, headers: ajax_headers
      body = JSON.parse(response.body)
      expect(body['result_count']).to be >= 2
      expect(body['html']).to include('searchterm')
    end
  end

  describe 'GET /nytimes' do
    it 'renders even without an nytimes user' do
      get '/nytimes'
      expect(response).to have_http_status(:ok)
    end

    context 'with nytimes user and puzzles' do
      let!(:nytimes_user) { create(:user, username: 'nytimes') }

      before do
        # Monday puzzle (wday=1)
        create(:crossword, :smaller, user: nytimes_user, created_at: Date.new(2024, 1, 15))
        # Saturday puzzle (wday=6)
        create(:crossword, :smaller, user: nytimes_user, created_at: Date.new(2024, 1, 20))
      end

      it 'renders successfully' do
        get '/nytimes'
        expect(response).to have_http_status(:ok)
      end

      it 'includes day-of-week tab labels' do
        get '/nytimes'
        body = response.body
        expect(body).to include('Mon')
        expect(body).to include('Tue')
        expect(body).to include('Sat')
        expect(body).to include('Sun')
      end

      it 'includes calendar data attribute with puzzle dates' do
        get '/nytimes'
        expect(response.body).to include('calendar-puzzles-value')
        expect(response.body).to include('2024-01-15')
        expect(response.body).to include('2024-01-20')
      end

      it 'shows puzzle counts in tab labels' do
        get '/nytimes'
        expect(response.body).to include('Mon (1)')
        expect(response.body).to include('Sat (1)')
        expect(response.body).to include('Tue (0)')
      end

      it 'groups puzzles by year in the default tab' do
        get '/nytimes'
        expect(response.body).to include('xw-year-header')
        expect(response.body).to include('2024')
      end

      it 'only renders puzzle cards for the default tab (Monday)' do
        get '/nytimes'
        body = response.body
        # Monday panel has real content (puzzle card)
        expect(body).to include('xw-puzzle-card')
        # Non-default panels have lazy-src instead of rendered content
        expect(body).to include('data-lazy-src="/nytimes/day/6"')
        expect(body).to include('data-lazy-src="/nytimes/day/0"')
      end

      it 'does not include data-lazy-src on the default tab panel' do
        get '/nytimes'
        expect(response.body).not_to include('data-lazy-src="/nytimes/day/1"')
      end

      it 'includes loading placeholder in deferred panels' do
        get '/nytimes'
        expect(response.body).to include('xw-loading-placeholder')
      end

      it 'sets calendar min/max to oldest/newest puzzle dates' do
        get '/nytimes'
        body = response.body
        expect(body).to include('calendar-min-value="2024-01-15"')
        expect(body).to include('calendar-max-value="2024-01-20"')
      end

      it 'includes crossword paths in puzzle dates JSON' do
        get '/nytimes'
        expect(response.body).to match(/calendar-puzzles-value.*crosswords\/\d+/)
      end
    end
  end

  describe 'GET /nytimes/day/:wday' do
    context 'without nytimes user' do
      it 'returns 400' do
        get '/nytimes/day/1'
        expect(response).to have_http_status(:bad_request)
      end
    end

    context 'with nytimes user and puzzles' do
      let!(:nytimes_user) { create(:user, username: 'nytimes') }

      before do
        # Monday puzzle (wday=1, DOW=1)
        create(:crossword, :smaller, user: nytimes_user, created_at: Date.new(2024, 1, 15))
        # Saturday puzzle (wday=6, DOW=6)
        create(:crossword, :smaller, user: nytimes_user, created_at: Date.new(2024, 1, 20))
      end

      it 'returns puzzle cards for Monday' do
        get '/nytimes/day/1'
        expect(response).to have_http_status(:ok)
        expect(response.body).to include('xw-puzzle-card')
        expect(response.body).to include('xw-year-header')
      end

      it 'returns puzzle cards for Saturday' do
        get '/nytimes/day/6'
        expect(response).to have_http_status(:ok)
        expect(response.body).to include('xw-puzzle-card')
      end

      it 'returns empty state for a day with no puzzles' do
        get '/nytimes/day/2'
        expect(response).to have_http_status(:ok)
        expect(response.body).to include('xw-empty-state')
        expect(response.body).to include('No puzzles imported')
      end

      it 'returns 400 for invalid wday' do
        get '/nytimes/day/8'
        expect(response).to have_http_status(:bad_request)
      end

      it 'returns 400 for negative wday' do
        get '/nytimes/day/-1'
        expect(response).to have_http_status(:bad_request)
      end
    end
  end

  describe 'GET /user_made' do
    it 'renders even without an nytimes user' do
      get '/user_made'
      expect(response).to have_http_status(:ok)
    end

    it 'sets the page title' do
      get '/user_made'
      expect(response.body).to include('User-Made Puzzles')
    end

    context 'with an nytimes user' do
      let!(:nyt_user) { create(:user, username: 'nytimes') }
      let!(:nyt_crossword) { create(:crossword, user: nyt_user) }
      let!(:user_crossword) { create(:crossword) }

      it 'excludes NYT puzzles' do
        get '/user_made'
        expect(response.body).to include(user_crossword.title)
        expect(response.body).not_to include(nyt_crossword.title)
      end
    end
  end
end
