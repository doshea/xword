RSpec.describe 'API', type: :request do
  # -------------------------------------------------------------------------
  # Api::CrosswordsController
  # -------------------------------------------------------------------------
  describe 'GET /api/crosswords/search' do
    let!(:crossword) { create(:predefined_five_by_five) }

    it 'returns crossword data as JSON when found' do
      get '/api/crosswords/search', params: { title: crossword.title }
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['title']).to eq crossword.title
      expect(json['rows']).to eq crossword.rows
      expect(json['cols']).to eq crossword.cols
    end

    it 'returns 404 when crossword is not found' do
      get '/api/crosswords/search', params: { title: 'Nonexistent Puzzle' }
      expect(response).to have_http_status(:not_found)
    end

    it 'includes comments when requested' do
      get '/api/crosswords/search', params: { title: crossword.title, include_comments: 'true' }
      json = JSON.parse(response.body)
      expect(json).to have_key('comments')
      expect(json).to have_key('comment_count')
    end
  end

  describe 'GET /api/crosswords/simple' do
    let!(:crossword) { create(:predefined_five_by_five) }

    it 'returns crossword as plain text' do
      get '/api/crosswords/simple', params: { title: crossword.title }
      expect(response).to have_http_status(:ok)
      expect(response.content_type).to include('text/plain')
    end

    it 'returns 404 when not found' do
      get '/api/crosswords/simple', params: { title: 'Nonexistent' }
      expect(response).to have_http_status(:not_found)
    end
  end

  # -------------------------------------------------------------------------
  # Api::UsersController
  # -------------------------------------------------------------------------
  describe 'GET /api/users' do
    let!(:user) { create(:user) }

    it 'returns a JSON array of users' do
      get '/api/users'
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json).to be_an(Array)
      expect(json.first).to have_key('username')
    end

    it 'does not expose sensitive fields' do
      get '/api/users'
      json = JSON.parse(response.body)
      user_data = json.first
      expect(user_data).not_to have_key('password_digest')
      expect(user_data).not_to have_key('email')
      expect(user_data).not_to have_key('auth_token')
    end
  end

  describe 'GET /api/users/search' do
    let!(:user) { create(:user) }

    it 'returns user data as JSON when found' do
      get '/api/users/search', params: { username: user.username }
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['username']).to eq user.username
    end

    it 'returns 404 when user is not found' do
      get '/api/users/search', params: { username: 'nobody_here' }
      expect(response).to have_http_status(:not_found)
    end
  end

  # -------------------------------------------------------------------------
  # ApiController (NYT endpoints — stub external HTTP calls)
  # -------------------------------------------------------------------------
  describe 'GET /api/nyt/:year/:month/:day' do
    let(:fake_json) { '{"title":"Test Puzzle","size":{"rows":15,"cols":15}}' }

    before do
      allow(Crossword).to receive(:get_github_nyt_from_date).and_return(fake_json)
    end

    it 'returns JSON data' do
      get '/api/nyt/2024/1/15'
      expect(response).to have_http_status(:ok)
      expect(response.content_type).to include('application/json')
    end
  end

  describe 'GET /api/nyt/:year/:month/:day (invalid JSON from upstream)' do
    before do
      allow(Crossword).to receive(:get_github_nyt_from_date).and_return('not valid json {{')
    end

    it 'returns 502 when upstream returns invalid JSON' do
      get '/api/nyt/2024/1/15.xml'
      expect(response).to have_http_status(:bad_gateway)
    end
  end

  describe 'GET /api/nyt_source/:year/:month/:day' do
    let(:fake_json) { '{"title":"NYT Puzzle","size":{"rows":15,"cols":15}}' }

    before do
      allow(Crossword).to receive(:get_nyt_from_date).and_return(fake_json)
    end

    it 'returns JSON data' do
      get '/api/nyt_source/2024/1/15'
      expect(response).to have_http_status(:ok)
      expect(response.content_type).to include('application/json')
    end
  end

  describe 'GET /api/nyt_source/:year/:month/:day (invalid JSON from upstream)' do
    before do
      allow(Crossword).to receive(:get_nyt_from_date).and_return('not valid json {{')
    end

    it 'returns 502 when upstream returns invalid JSON' do
      get '/api/nyt_source/2024/1/15.xml'
      expect(response).to have_http_status(:bad_gateway)
    end
  end
end
