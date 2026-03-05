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

  # -------------------------------------------------------------------------
  # ApiController#clue_suggestions — edit page suggest feature
  # -------------------------------------------------------------------------
  describe 'GET /api/clue_suggestions' do
    it 'returns 401 when not logged in' do
      get '/api/clue_suggestions', params: { word: 'OREO' }
      expect(response).to have_http_status(:unauthorized)
    end

    context 'when logged in' do
      let(:user) { create(:user, :with_test_password) }
      before { log_in_as(user) }

      it 'returns empty suggestions for a blank word' do
        get '/api/clue_suggestions', params: { word: '' }
        expect(response).to have_http_status(:ok)
        data = JSON.parse(response.body)
        expect(data['suggestions']).to eq([])
      end

      it 'returns empty suggestions for an unknown word' do
        get '/api/clue_suggestions', params: { word: 'XYZZYPLUGH' }
        expect(response).to have_http_status(:ok)
        data = JSON.parse(response.body)
        expect(data['word']).to eq('XYZZYPLUGH')
        expect(data['suggestions']).to eq([])
      end

      it 'returns suggestions for a known word with phrases' do
        word = Word.find_or_create_by!(content: 'OREO')
        phrase = Phrase.find_or_create_by_content('Sandwich cookie brand')
        Clue.create!(content: 'Sandwich cookie brand', word: word, phrase: phrase, difficulty: 2)
        Clue.create!(content: 'Sandwich cookie brand', word: word, phrase: phrase, difficulty: 3)

        get '/api/clue_suggestions', params: { word: 'oreo' }
        expect(response).to have_http_status(:ok)
        data = JSON.parse(response.body)
        expect(data['word']).to eq('OREO')
        expect(data['suggestions'].length).to be >= 1
        expect(data['suggestions'].first['text']).to eq('Sandwich cookie brand')
        expect(data['suggestions'].first['usage_count']).to eq(2)
      end

      it 'excludes clues with default content' do
        word = Word.find_or_create_by!(content: 'TESTWORD')
        phrase = Phrase.find_or_create_by_content(Clue::DEFAULT_CONTENT)
        Clue.create!(content: Clue::DEFAULT_CONTENT, word: word, phrase: phrase, difficulty: 1)

        get '/api/clue_suggestions', params: { word: 'TESTWORD' }
        data = JSON.parse(response.body)
        expect(data['suggestions']).to eq([])
      end

      it 'limits results to 10' do
        word = Word.find_or_create_by!(content: 'POPULAR')
        12.times do |i|
          phrase = Phrase.find_or_create_by_content("Clue variation #{i}")
          Clue.create!(content: "Clue variation #{i}", word: word, phrase: phrase, difficulty: 1)
        end

        get '/api/clue_suggestions', params: { word: 'POPULAR' }
        data = JSON.parse(response.body)
        expect(data['suggestions'].length).to eq(10)
      end
    end
  end

end
