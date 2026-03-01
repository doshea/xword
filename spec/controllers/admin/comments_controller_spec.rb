describe Admin::CommentsController do
  let(:admin)     { create(:admin) }
  let(:user)      { create(:user) }
  let(:crossword) { create(:crossword) }
  let(:comment)   { create(:comment, user: user, crossword: crossword) }

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
      before { get :edit, params: { id: comment.id } }
      it { should respond_with(200) }
    end

    describe 'PATCH #update' do
      before { patch :update, params: { id: comment.id, comment: { content: 'Edited content' } } }
      it { should redirect_to(admin_comments_path) }
      it 'updates the comment' do
        expect(comment.reload.content).to eq 'Edited content'
      end
    end

    describe 'DELETE #destroy' do
      before { comment }
      it 'destroys the comment' do
        expect {
          delete :destroy, params: { id: comment.id }
        }.to change(Comment, :count).by(-1)
      end
      it 'redirects to index' do
        delete :destroy, params: { id: comment.id }
        expect(response).to redirect_to(admin_comments_path)
      end
    end
  end
end
