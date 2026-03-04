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
      it 'renders without errors and shows all crosswords' do
        create(:crossword, :smaller)
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
    before { get '/about' }

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

      it 'groups puzzles by year within each tab' do
        get '/nytimes'
        expect(response.body).to include('xw-year-header')
        expect(response.body).to include('2024')
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

  describe 'GET /user_made' do
    it 'renders even without an nytimes user' do
      get '/user_made'
      expect(response).to have_http_status(:ok)
    end
  end
end
