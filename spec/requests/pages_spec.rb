RSpec.describe 'Pages', type: :request do
  let(:test_password) { 'password123' }
  let(:user)      { create(:user, password: test_password, password_confirmation: test_password) }

  def log_in_as(u)
    post '/login', params: { username: u.username, password: test_password }
  end

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
    it 'renders the about page' do
      get '/about'
      expect(response).to have_http_status(:ok)
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
    it 'renders the search page' do
      get '/search', params: { query: 'test' }
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'GET /nytimes' do
    it 'renders even without an nytimes user' do
      get '/nytimes'
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'GET /user_made' do
    it 'renders even without an nytimes user' do
      get '/user_made'
      expect(response).to have_http_status(:ok)
    end
  end
end
