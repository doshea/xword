describe Admin::SolutionsController do
  let(:user)      { create(:user) }
  let(:crossword) { create(:crossword, :smaller) }
  let(:record)    { create(:solution, user: user, crossword: crossword) }

  it_behaves_like 'admin CRUD controller', model_class: Solution

  context 'as admin' do
    before { log_in(create(:admin)) }

    describe 'GET #index (nil associations)' do
      render_views

      it 'renders when solution has nil user and nil crossword' do
        record.update_column(:user_id, nil)
        record.update_column(:crossword_id, nil)
        get :index
        expect(response).to have_http_status(200)
      end
    end

    describe 'GET #edit (nil associations)' do
      render_views

      it 'renders when solution has nil user and nil crossword' do
        record.update_column(:user_id, nil)
        record.update_column(:crossword_id, nil)
        get :edit, params: { id: record.id }
        expect(response).to have_http_status(200)
      end
    end
  end
end
