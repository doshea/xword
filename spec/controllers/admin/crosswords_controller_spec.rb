describe Admin::CrosswordsController do
  let(:admin)     { create(:admin) }
  let(:crossword) { create(:crossword, :smaller) }

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
      before { get :edit, params: { id: crossword.id } }
      it { should respond_with(200) }
    end

    describe 'PATCH #update' do
      before { patch :update, params: { id: crossword.id, crossword: { title: 'New Title' } } }
      it { should redirect_to(admin_crosswords_path) }
      it 'updates the crossword title' do
        expect(crossword.reload.title).to eq 'New Title'
      end
    end

    describe 'DELETE #destroy' do
      before { crossword }
      it 'destroys the crossword' do
        expect {
          delete :destroy, params: { id: crossword.id }
        }.to change(Crossword, :count).by(-1)
      end
      it 'redirects to index' do
        delete :destroy, params: { id: crossword.id }
        expect(response).to redirect_to(admin_crosswords_path)
      end
    end
  end
end
