describe SolutionsController do
  let(:user)      { create(:user) }
  let(:crossword) { create(:crossword, :smaller) }
  let(:solution)  { create(:solution, user: user, crossword: crossword) }

  def log_in(u)
    session[:user_id] = u.id
  end

  context 'before_actions' do
    it { should use_before_action(:ensure_owner_or_partner) }
  end

  describe 'GET #show' do
    context 'non-team solution' do
      # show redirects to the associated crossword (not a team solution)
      before { get :show, params: { id: solution.id } }
      it { should redirect_to(crossword) }
    end
  end

  describe 'PATCH #update' do
    # update.js.erb is called via $.ajax from solve_funcs.js (format.js, not Turbo)
    before do
      log_in(user)
      patch :update, params: { id: solution.id, letters: 'ABCDE' }, format: :js
    end

    it { should respond_with(200) }
    it 'updates the solution letters' do
      expect(solution.reload.letters).to eq 'ABCDE'
    end

    context 'with a null/invalid id (stale JS sending solution_id before it was set)' do
      # guard_null_solution_id runs before find_object to absorb these silently without
      # setting a flash error that would persist and show up on subsequent pages
      it 'returns 200 and sets no flash' do
        patch :update, params: { id: 'null', letters: 'X' }, format: :js
        expect(response).to have_http_status(200)
        expect(flash[:error]).to be_nil
      end
    end
  end

  describe 'DELETE #destroy' do
    context 'as the solution owner' do
      before { log_in(user); solution }
      it 'destroys the solution' do
        expect {
          delete :destroy, params: { id: solution.id }
        }.to change(Solution, :count).by(-1)
      end
      it { delete :destroy, params: { id: solution.id }; should redirect_to(:root) }
    end

    context 'as an unrelated user' do
      let(:other) { create(:user) }
      before { log_in(other); solution }
      it 'does not destroy the solution' do
        expect {
          delete :destroy, params: { id: solution.id }
        }.not_to change(Solution, :count)
      end
    end
  end
end
