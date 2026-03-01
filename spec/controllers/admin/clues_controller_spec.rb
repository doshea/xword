describe Admin::CluesController do
  let(:admin)    { create(:admin) }
  let(:crossword) { create(:crossword, :smaller) }
  let(:clue)     { crossword.cells.find(&:across_clue).across_clue }

  def log_in_admin
    session[:user_id] = admin.id
  end

  context 'before_actions' do
    it { should use_before_action(:ensure_admin) }
  end

  context 'when not logged in' do
    it 'redirects to unauthorized_path' do
      get :index
      expect(response).to redirect_to(unauthorized_path)
    end
  end

  context 'as admin' do
    before { log_in_admin }

    describe 'GET #index' do
      before { get :index }
      it { should respond_with(200) }
    end

    describe 'GET #edit' do
      before { get :edit, params: { id: clue.id } }
      it { should respond_with(200) }
    end

    describe 'PATCH #update' do
      before { patch :update, params: { id: clue.id, clue: { content: 'New clue', difficulty: 2 } } }
      it { should redirect_to(admin_clues_path) }
      it 'updates the clue content' do
        expect(clue.reload.content).to eq 'New clue'
      end
    end

    describe 'DELETE #destroy' do
      before { clue }
      it 'destroys the clue' do
        expect {
          delete :destroy, params: { id: clue.id }
        }.to change(Clue, :count).by(-1)
      end
      it 'redirects to index' do
        delete :destroy, params: { id: clue.id }
        expect(response).to redirect_to(admin_clues_path)
      end
    end
  end
end
