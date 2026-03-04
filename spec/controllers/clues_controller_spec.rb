describe CluesController do
  # Clues are created by Crossword callbacks; pull from a crossword's cells.
  let(:user) { create(:user) }
  let(:crossword) { create(:crossword, :smaller, user: user) }
  let(:clue) { crossword.cells.find(&:across_clue).across_clue }

  describe 'GET #show' do
    before { get :show, params: { id: clue.id } }

    it { should respond_with(200) }
    it 'assigns @clue' do
      expect(assigns(:clue)).to eq clue
    end
  end

  describe 'GET #show for an orphaned clue' do
    let(:orphan) { create(:clue) }

    it 'redirects to error page' do
      get :show, params: { id: orphan.id }
      expect(response).to redirect_to(error_path)
    end
  end

  describe 'PATCH #update' do
    before do
      log_in(user)
      patch :update, params: { id: clue.id, clue: { content: 'Updated clue content' } }
    end

    it { should respond_with(200) }
    it 'updates the clue content' do
      expect(clue.reload.content).to eq 'Updated clue content'
    end
  end

  describe 'PATCH #update when not logged in' do
    before { patch :update, params: { id: clue.id, clue: { content: 'Nope' } } }
    it 'redirects to account_required with redirect param' do
      expect(response.location).to start_with("http://test.host#{account_required_path}")
    end
  end
end
