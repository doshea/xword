describe Admin::SolutionsController do
  let(:admin)    { create(:admin) }
  let(:user)     { create(:user) }
  let(:crossword) { create(:crossword, :smaller) }
  let(:solution) { create(:solution, user: user, crossword: crossword) }

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
      before { get :edit, params: { id: solution.id } }
      it { should respond_with(200) }
    end

    describe 'DELETE #destroy' do
      before { solution }
      it 'destroys the solution' do
        expect {
          delete :destroy, params: { id: solution.id }
        }.to change(Solution, :count).by(-1)
      end
      it 'redirects to index' do
        delete :destroy, params: { id: solution.id }
        expect(response).to redirect_to(admin_solutions_path)
      end
    end
  end
end
