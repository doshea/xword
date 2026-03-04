RSpec.describe 'POST /home/load_more', type: :request do
  let(:user) { create(:user, :with_test_password) }

  describe 'as a logged-in user' do
    before { log_in_as(user) }

    it 'returns turbo stream with puzzle cards for unstarted scope' do
      post home_load_more_path, params: { scope: 'unstarted', page: 1 },
           headers: { 'Accept' => Mime[:turbo_stream].to_s }
      expect(response).to have_http_status(:ok)
      expect(response.media_type).to eq Mime[:turbo_stream].to_s
    end

    it 'returns turbo stream for in_progress scope' do
      post home_load_more_path, params: { scope: 'in_progress', page: 1 },
           headers: { 'Accept' => Mime[:turbo_stream].to_s }
      expect(response).to have_http_status(:ok)
    end

    it 'returns turbo stream for solved scope' do
      post home_load_more_path, params: { scope: 'solved', page: 1 },
           headers: { 'Accept' => Mime[:turbo_stream].to_s }
      expect(response).to have_http_status(:ok)
    end

    it 'rejects invalid scope' do
      post home_load_more_path, params: { scope: 'bogus', page: 1 },
           headers: { 'Accept' => Mime[:turbo_stream].to_s }
      expect(response).to have_http_status(:bad_request)
    end
  end

  describe 'as an anonymous user' do
    it 'allows unstarted scope' do
      post home_load_more_path, params: { scope: 'unstarted', page: 1 },
           headers: { 'Accept' => Mime[:turbo_stream].to_s }
      expect(response).to have_http_status(:ok)
    end

    it 'rejects non-unstarted scopes' do
      post home_load_more_path, params: { scope: 'in_progress', page: 1 },
           headers: { 'Accept' => Mime[:turbo_stream].to_s }
      expect(response).to have_http_status(:bad_request)
    end
  end
end
