RSpec.describe 'API', type: :request do
  # -------------------------------------------------------------------------
  # ApiController#nyt — NYT GitHub proxy
  # -------------------------------------------------------------------------
  describe 'GET /api/nyt/:year/:month/:day' do
    let(:fake_json) { '{"title":"Test Puzzle","size":{"rows":15,"cols":15}}' }

    before do
      allow(NytPuzzleFetcher).to receive(:from_github).and_return(fake_json)
    end

    it 'returns JSON data' do
      get '/api/nyt/2024/1/15'
      expect(response).to have_http_status(:ok)
      expect(response.content_type).to include('application/json')
    end
  end

  describe 'GET /api/nyt/:year/:month/:day (invalid JSON from upstream)' do
    before do
      allow(NytPuzzleFetcher).to receive(:from_github).and_return('not valid json {{')
    end

    it 'returns 502 when upstream returns invalid JSON' do
      get '/api/nyt/2024/1/15.xml'
      expect(response).to have_http_status(:bad_gateway)
    end
  end

  # -------------------------------------------------------------------------
  # ApiController#friends — team invite modal
  # -------------------------------------------------------------------------
  describe 'GET /api/friends' do
    it 'returns 401 when not logged in' do
      get '/api/friends'
      expect(response).to have_http_status(:unauthorized)
    end

    context 'when logged in' do
      let(:user) { create(:user, :with_test_password) }
      before { log_in_as(user) }

      it 'returns a JSON array' do
        get '/api/friends'
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)).to be_an(Array)
      end
    end
  end

end
