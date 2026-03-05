describe UnpublishedCrosswordsController do
  let(:user) { create(:user) }
  let(:ucw)  { create(:unpublished_crossword, user: user) }

  describe 'before_actions' do
    it { should use_before_action(:find_object) }
    it { should use_before_action(:ensure_owner_or_admin) }
    it { should use_before_action(:ensure_logged_in) }
  end

  # -----------------------------------------------------------------------
  # GET #edit
  # -----------------------------------------------------------------------
  describe 'GET #edit' do
    context 'as owner' do
      before { log_in(user); get :edit, params: { id: ucw.id } }

      it { should respond_with(200) }
      it 'assigns @clue_numbers' do
        expect(assigns(:clue_numbers)).to be_a Hash
        expect(assigns(:clue_numbers).keys).to contain_exactly(:across, :down)
      end
    end

    context 'as non-owner' do
      let(:other_user) { create(:user) }
      before { log_in(other_user); get :edit, params: { id: ucw.id } }

      it { should respond_with(302) }
    end

    context 'anonymous' do
      before { get :edit, params: { id: ucw.id } }
      it { should respond_with(302) }
    end
  end

  # -----------------------------------------------------------------------
  # PUT #update (title / description / switches)
  # -----------------------------------------------------------------------
  describe 'PUT #update' do
    context 'as owner' do
      before { log_in(user) }

      it 'updates the title' do
        put :update, params: { id: ucw.id, unpublished_crossword: { title: 'New Title' } }
        expect(response).to have_http_status(:ok)
        expect(ucw.reload.title).to eq 'New Title'
      end

      it 'updates the description' do
        put :update, params: { id: ucw.id, unpublished_crossword: { description: 'New desc' } }
        expect(response).to have_http_status(:ok)
        expect(ucw.reload.description).to eq 'New desc'
      end

      it 'updates mirror_voids toggle' do
        put :update, params: { id: ucw.id, unpublished_crossword: { mirror_voids: false } }
        expect(response).to have_http_status(:ok)
        expect(ucw.reload.mirror_voids).to be false
      end
    end

    context 'as non-owner' do
      let(:other_user) { create(:user) }
      before { log_in(other_user) }

      it 'redirects away' do
        put :update, params: { id: ucw.id, unpublished_crossword: { title: 'Hacked' } }
        expect(response).to have_http_status(302)
        expect(ucw.reload.title).not_to eq 'Hacked'
      end
    end
  end

  # -----------------------------------------------------------------------
  # PATCH #update_letters
  # -----------------------------------------------------------------------
  describe 'PATCH #update_letters' do
    before { log_in(user) }

    let(:area) { ucw.rows * ucw.cols }
    let(:letters) { Array.new(area, 'A') }
    let(:circles) { ' ' * area }

    context 'with JSON format (current client)' do
      it 'updates letters and echoes save_counter in JSON' do
        patch :update_letters, params: {
          id: ucw.id,
          letters: letters,
          circles: circles,
          across_clues: Array.new(area),
          down_clues: Array.new(area),
          save_counter: '0.12345'
        }, format: :json

        expect(response).to have_http_status(:ok)
        body = JSON.parse(response.body)
        expect(body['save_counter']).to eq '0.12345'
        expect(ucw.reload.letters).to eq letters
      end
    end

    context 'with JS format (legacy fallback)' do
      it 'updates letters and renders js response' do
        patch :update_letters, params: {
          id: ucw.id,
          letters: letters,
          circles: circles,
          across_clues: Array.new(area),
          down_clues: Array.new(area),
          save_counter: '0.12345'
        }, format: :js

        expect(response).to have_http_status(:ok)
        expect(ucw.reload.letters).to eq letters
      end
    end

    it 'converts "0" values to nil (void) and empty strings to "" (non-void empty)' do
      mixed_letters = letters.dup
      mixed_letters[0] = '0'
      mixed_letters[3] = ''

      patch :update_letters, params: {
        id: ucw.id,
        letters: mixed_letters,
        circles: circles,
        across_clues: Array.new(area),
        down_clues: Array.new(area),
        save_counter: '0.999'
      }, format: :json

      saved_letters = ucw.reload.letters
      expect(saved_letters[0]).to be_nil   # "0" → void (nil)
      expect(saved_letters[3]).to eq ''    # "" → non-void empty (not nil)
      expect(saved_letters[1]).to eq 'A'   # letter preserved
    end

    it 'converts integer 0 to nil (void) and space to "" (non-void empty)' do
      mixed_letters = letters.dup
      mixed_letters[0] = 0       # JS sends integer 0 for void cells via JSON
      mixed_letters[1] = ' '     # JS sends space for empty non-void cells

      patch :update_letters, params: {
        id: ucw.id,
        letters: mixed_letters,
        circles: circles,
        across_clues: Array.new(area),
        down_clues: Array.new(area),
        save_counter: '0.888'
      }, format: :json

      saved_letters = ucw.reload.letters
      expect(saved_letters[0]).to be_nil   # integer 0 → void (nil)
      expect(saved_letters[1]).to eq ''    # space → non-void empty (not nil)
      expect(saved_letters[2]).to eq 'A'   # normal letter preserved
    end
  end

  # -----------------------------------------------------------------------
  # PATCH #add_potential_word (Turbo Stream)
  # -----------------------------------------------------------------------
  describe 'PATCH #add_potential_word' do
    before do
      log_in(user)
      request.accept = Mime[:turbo_stream].to_s
    end

    it 'adds a new word and responds with turbo stream' do
      patch :add_potential_word, params: { id: ucw.id, word: 'hello' }
      expect(response).to have_http_status(:ok)
      expect(assigns(:word)).to eq 'HELLO'
      expect(assigns(:added)).to be true
      expect(ucw.reload.potential_words).to include('HELLO')
    end

    it 'rejects duplicate words' do
      ucw.update!(potential_words: ['HELLO'])
      patch :add_potential_word, params: { id: ucw.id, word: 'hello' }
      expect(response).to have_http_status(:ok)
      expect(assigns(:added)).to be false
    end

    it 'upcases the word' do
      patch :add_potential_word, params: { id: ucw.id, word: 'world' }
      expect(assigns(:word)).to eq 'WORLD'
    end
  end

  # -----------------------------------------------------------------------
  # DELETE #remove_potential_word (Turbo Stream)
  # -----------------------------------------------------------------------
  describe 'DELETE #remove_potential_word' do
    before do
      ucw.update!(potential_words: %w[HELLO WORLD])
      log_in(user)
      request.accept = Mime[:turbo_stream].to_s
    end

    it 'removes the word and responds with turbo stream' do
      delete :remove_potential_word, params: { id: ucw.id, word: 'hello' }
      expect(response).to have_http_status(:ok)
      expect(assigns(:word)).to eq 'HELLO'
      expect(ucw.reload.potential_words).not_to include('HELLO')
      expect(ucw.potential_words).to include('WORLD')
    end
  end

  # -----------------------------------------------------------------------
  # POST #create
  # -----------------------------------------------------------------------
  describe 'POST #create' do
    context 'logged in' do
      before { log_in(user) }

      it 'creates a new unpublished crossword and redirects to edit' do
        expect {
          post :create, params: { unpublished_crossword: { title: 'Test Puzzle', rows: 5, cols: 5 } }
        }.to change(UnpublishedCrossword, :count).by(1)
        expect(response).to redirect_to(edit_unpublished_crossword_path(UnpublishedCrossword.last))
      end

      it 'populates arrays on create' do
        post :create, params: { unpublished_crossword: { title: 'Test Puzzle', rows: 5, cols: 5 } }
        ucw_new = UnpublishedCrossword.last
        expect(ucw_new.letters.length).to eq 25
        expect(ucw_new.circles.length).to eq 25
      end
    end

    context 'anonymous' do
      it 'redirects to account_required' do
        post :create, params: { unpublished_crossword: { title: 'Test', rows: 5, cols: 5 } }
        expect(response.location).to start_with("http://test.host#{account_required_path}")
      end
    end
  end
end
