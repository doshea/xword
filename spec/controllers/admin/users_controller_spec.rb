describe Admin::UsersController do
  let(:admin)      { create(:admin) }
  let(:target_user) { create(:user) }

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
      before { get :edit, params: { id: target_user.id } }
      it { should respond_with(200) }
    end

    describe 'PATCH #update' do
      before { patch :update, params: { id: target_user.id, user: { location: 'New York' } } }
      it { should redirect_to(admin_users_path) }
      it 'updates the user' do
        expect(target_user.reload.location).to eq 'New York'
      end
    end

    describe 'DELETE #destroy' do
      before { target_user }
      it 'destroys the user' do
        expect {
          delete :destroy, params: { id: target_user.id }
        }.to change(User, :count).by(-1)
      end
      it 'redirects to index' do
        delete :destroy, params: { id: target_user.id }
        expect(response).to redirect_to(admin_users_path)
      end
    end
  end
end
