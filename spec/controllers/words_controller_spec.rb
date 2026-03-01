describe WordsController do
  # Words are a global dictionary table (no factory); create directly.
  let(:word) { Word.create!(content: 'HELLO') }

  describe 'GET #show' do
    before { get :show, params: { id: word.id } }

    it { should respond_with(200) }
    it 'assigns @word' do
      expect(assigns(:word)).to eq word
    end
    it 'assigns @clues as an array' do
      expect(assigns(:clues)).to be_an Array
    end
  end

  describe 'POST #match' do
    # match renders match.turbo_stream.erb; word_match hits an external URL so stub it.
    before do
      request.accept = Mime[:turbo_stream].to_s
      allow(Word).to receive(:word_match).and_return(%w[HELLO WORLD])
      post :match, params: { pattern: '?????' }
    end

    it { should respond_with(200) }
    it 'assigns @results' do
      expect(assigns(:results)).to eq %w[HELLO WORLD]
    end
  end
end