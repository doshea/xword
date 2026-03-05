RSpec.describe 'AJAX endpoints with CSRF protection', type: :request do
  let_it_be(:user)      { create(:user, :with_test_password) }
  let_it_be(:crossword) { create(:predefined_five_by_five) }
  let(:correct_letters) { crossword.letters }
  let(:blank_letters)   { correct_letters.gsub(/[^_]/, ' ') }
  # Eager create: must exist before csrf_token visits show page (which does find_or_create_by)
  let!(:solution) { create(:solution, user: user, crossword: crossword, letters: blank_letters) }

  let(:json_headers) do
    { 'Accept' => 'application/json', 'X-Requested-With' => 'XMLHttpRequest' }
  end

  let(:js_headers) do
    { 'Accept' => 'text/javascript', 'X-Requested-With' => 'XMLHttpRequest' }
  end

  around do |example|
    ActionController::Base.allow_forgery_protection = true
    example.run
  ensure
    ActionController::Base.allow_forgery_protection = false
  end

  # Get a valid CSRF token by visiting a page, then log in with it
  def log_in_with_csrf(user)
    get '/login'
    token = response.body[/name="csrf-token" content="([^"]+)"/, 1]
    post '/login',
         params: { username: user.username, password: RequestAuthHelpers::TEST_PASSWORD, authenticity_token: token }
  end

  def csrf_token
    get "/crosswords/#{crossword.id}"
    response.body[/name="csrf-token" content="([^"]+)"/, 1]
  end

  # -------------------------------------------------------------------------
  # POST /crosswords/:id/check_cell — requires CSRF
  # -------------------------------------------------------------------------
  describe 'POST /crosswords/:id/check_cell' do
    it 'is rejected without a CSRF token' do
      post "/crosswords/#{crossword.id}/check_cell",
           params: { letters: ['A'], indices: ['0'] },
           headers: json_headers

      expect(response).to have_http_status(:unprocessable_content)
    end

    it 'succeeds when the CSRF token is provided via X-CSRF-Token header' do
      token = csrf_token
      post "/crosswords/#{crossword.id}/check_cell",
           params: { letters: ['A'], indices: ['0'] },
           headers: json_headers.merge('X-CSRF-Token' => token)

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body['mismatches']['0']).to be false
    end
  end

  # -------------------------------------------------------------------------
  # POST /crosswords/:id/check_completion — requires CSRF
  # -------------------------------------------------------------------------
  describe 'POST /crosswords/:id/check_completion' do
    it 'is rejected without a CSRF token' do
      post "/crosswords/#{crossword.id}/check_completion",
           params: { letters: correct_letters },
           headers: json_headers

      expect(response).to have_http_status(:unprocessable_content)
    end

    it 'succeeds when the CSRF token is provided' do
      log_in_with_csrf(user)
      token = csrf_token
      post "/crosswords/#{crossword.id}/check_completion",
           params: { letters: correct_letters, solution_id: solution.id },
           headers: json_headers.merge('X-CSRF-Token' => token)

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body['correct']).to be true
    end
  end

  # -------------------------------------------------------------------------
  # PUT /solutions/:id — requires CSRF
  # -------------------------------------------------------------------------
  describe 'PUT /solutions/:id' do
    it 'succeeds when CSRF token is in the X-CSRF-Token header' do
      log_in_with_csrf(user)
      token = csrf_token
      put "/solutions/#{solution.id}",
          params: { letters: blank_letters, save_counter: '0.1' },
          headers: json_headers.merge('X-CSRF-Token' => token)

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body['save_counter']).to eq '0.1'
    end

    it 'succeeds when authenticity_token is in form data' do
      log_in_with_csrf(user)
      token = csrf_token
      put "/solutions/#{solution.id}",
          params: { letters: blank_letters, save_counter: '0.1', authenticity_token: token },
          headers: json_headers

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body['save_counter']).to eq '0.1'
    end
  end

  # -------------------------------------------------------------------------
  # PATCH /unpublished_crosswords/:id/update_letters — header-only CSRF
  # -------------------------------------------------------------------------
  describe 'PATCH /unpublished_crosswords/:id/update_letters' do
    let(:ucw) { create(:unpublished_crossword, user: user) }

    it 'succeeds with X-CSRF-Token header only (no authenticity_token in params)' do
      log_in_with_csrf(user)
      token = csrf_token
      letters = Array.new(ucw.rows * ucw.cols) { ('A'..'Z').to_a.sample }
      patch "/unpublished_crosswords/#{ucw.id}/update_letters",
            params: { letters: letters, circles: '', across_clues: [], down_clues: [], save_counter: '0.5' },
            headers: json_headers.merge('X-CSRF-Token' => token)

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body['save_counter']).to eq '0.5'
    end
  end

  # -------------------------------------------------------------------------
  # PATCH /solutions/:id/team_update — header-only CSRF
  # -------------------------------------------------------------------------
  describe 'PATCH /solutions/:id/team_update' do
    let(:team_solution) { create(:solution, :team, user: user, crossword: crossword, letters: blank_letters) }

    it 'succeeds with X-CSRF-Token header only (no authenticity_token in params)' do
      log_in_with_csrf(user)
      token = csrf_token
      patch "/solutions/#{team_solution.id}/team_update",
            params: { letter: 'A', col: 0, row: 0, solver_id: 'abc123',
                      red: 100, green: 150, blue: 200 },
            headers: { 'X-CSRF-Token' => token }

      expect(response).to have_http_status(:ok)
    end
  end

  # -------------------------------------------------------------------------
  # POST /solutions/:id/join_team — header-only CSRF
  # -------------------------------------------------------------------------
  describe 'POST /solutions/:id/join_team' do
    let(:team_solution) { create(:solution, :team, user: user, crossword: crossword, letters: blank_letters) }

    it 'succeeds with X-CSRF-Token header only (no authenticity_token in params)' do
      log_in_with_csrf(user)
      token = csrf_token
      post "/solutions/#{team_solution.id}/join_team",
           params: { display_name: 'TestUser', solver_id: 'abc123',
                     red: 100, green: 150, blue: 200 },
           headers: { 'X-CSRF-Token' => token }

      expect(response).to have_http_status(:ok)
    end
  end
end
