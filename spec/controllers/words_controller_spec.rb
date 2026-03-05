describe WordsController do
  # Words are a global dictionary table (no factory); create directly.
  let(:word) { Word.create!(content: 'HELLO') }

  describe 'GET #show' do
    before { get :show, params: { id: word.id } }

    it { expect(response).to have_http_status(:ok) }
    it 'assigns @word' do
      expect(assigns(:word)).to eq word
    end
    it 'assigns @clues as a relation' do
      expect(assigns(:clues)).to respond_to(:to_a)
    end
  end

  describe 'POST #match' do
    before { request.accept = Mime[:turbo_stream].to_s }

    context 'with successful external lookup' do
      before do
        allow(Word).to receive(:word_match).and_return(%w[HELLO WORLD])
        post :match, params: { pattern: '?????' }
      end

      it { expect(response).to have_http_status(:ok) }
      it 'assigns @results' do
        expect(assigns(:results)).to eq %w[HELLO WORLD]
      end
    end

    context 'when external lookup fails' do
      before do
        allow(Word).to receive(:word_match).and_return([])
        post :match, params: { pattern: '?????' }
      end

      it { expect(response).to have_http_status(:ok) }
      it 'assigns empty results' do
        expect(assigns(:results)).to eq []
      end
    end

    context 'with blank pattern' do
      before do
        post :match, params: { pattern: '' }
      end

      it { expect(response).to have_http_status(:ok) }
      it 'assigns empty results without calling word_match' do
        expect(assigns(:results)).to eq []
      end
    end

    context 'with nil pattern (missing param)' do
      before do
        post :match, params: {}
      end

      it { expect(response).to have_http_status(:ok) }
      it 'assigns empty results' do
        expect(assigns(:results)).to eq []
      end
    end

    context 'pattern normalization' do
      it 'converts underscores to question marks' do
        allow(Word).to receive(:word_match).and_return([])
        post :match, params: { pattern: 'HE__O' }
        expect(Word).to have_received(:word_match).with('HE??O')
      end

      it 'converts hyphens to question marks' do
        allow(Word).to receive(:word_match).and_return([])
        post :match, params: { pattern: 'HE--O' }
        expect(Word).to have_received(:word_match).with('HE??O')
      end

      it 'upcases results' do
        allow(Word).to receive(:word_match).and_return(%w[hello world])
        post :match, params: { pattern: '?????' }
        expect(assigns(:results)).to eq %w[HELLO WORLD]
      end
    end
  end
end
