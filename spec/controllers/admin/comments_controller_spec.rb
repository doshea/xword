describe Admin::CommentsController do
  let(:user)      { create(:user) }
  let(:crossword) { create(:crossword) }
  let(:record)    { create(:comment, user: user, crossword: crossword) }

  it_behaves_like 'admin CRUD controller',
    model_class: Comment,
    update_params: { comment: { content: 'Edited content' } },
    verify_update: ->(r) { expect(r.content).to eq 'Edited content' }

  context 'as admin' do
    before { log_in(create(:admin)) }

    describe 'GET #index (nil user)' do
      render_views

      it 'renders when comment has nil user' do
        record.update_column(:user_id, nil)
        get :index
        expect(response).to have_http_status(200)
      end
    end
  end
end
