describe PagesController do
  context 'anonymous' do
    context 'GET #home' do
      before { get :home }

      it { should respond_with(:success) }
    end
  end

  context 'logged_in' do
    before { get :home }
    it { should respond_with(:success) }
  end

  # ---------------------------------------------------------------------------
  # GET #live_search (JS format — $.ajax dataType:'script' from global.js)
  # ---------------------------------------------------------------------------
  describe 'GET #live_search' do
    before do
      request.env["HTTP_X_REQUESTED_WITH"] = "XMLHttpRequest"
    end

    context 'with matching results' do
      let!(:user)      { create(:user, username: 'puzzlemaker') }
      let!(:crossword) { create(:crossword) }
      let!(:word)      { Word.create!(content: 'PUZZLE') }

      before { get :live_search, params: { query: 'puzzle' }, format: :js }

      it { should respond_with(200) }
      it 'assigns @result_count' do
        expect(assigns(:result_count)).to be >= 1
      end
    end

    context 'with no results' do
      before { get :live_search, params: { query: 'zzzznotfound' }, format: :js }

      it { should respond_with(200) }
      it 'assigns zero result_count' do
        expect(assigns(:result_count)).to eq 0
      end
    end

    context 'with blank query' do
      before { get :live_search, params: { query: '' }, format: :js }

      it { should respond_with(200) }
      it 'assigns empty collections' do
        expect(assigns(:users)).to be_empty
        expect(assigns(:crosswords)).to be_empty
        expect(assigns(:words)).to be_empty
      end
    end
  end

  # ---------------------------------------------------------------------------
  # GET #search (HTML)
  # ---------------------------------------------------------------------------
  describe 'GET #search' do
    before { get :search, params: { query: 'test' } }

    it { should respond_with(200) }
    it 'assigns @query' do
      expect(assigns(:query)).to eq 'test'
    end
  end
end
