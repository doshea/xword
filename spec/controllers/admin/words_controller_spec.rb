describe Admin::WordsController do
  let(:admin) { create(:admin) }
  let(:word)  { Word.create!(content: 'PUZZLE') }

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
      before { get :edit, params: { id: word.id } }
      it { should respond_with(200) }
    end

    describe 'PATCH #update' do
      before { patch :update, params: { id: word.id, word: { content: 'UPDATED' } } }
      it { should redirect_to(admin_words_path) }
      it 'updates the word content' do
        expect(word.reload.content).to eq 'UPDATED'
      end
    end

    describe 'DELETE #destroy' do
      before { word }
      it 'destroys the word' do
        expect {
          delete :destroy, params: { id: word.id }
        }.to change(Word, :count).by(-1)
      end
      it 'redirects to index' do
        delete :destroy, params: { id: word.id }
        expect(response).to redirect_to(admin_words_path)
      end
    end
  end
end
