describe Admin::UsersController do
  let(:record) { create(:user) }

  it_behaves_like 'admin CRUD controller',
    model_class: User,
    update_params: { user: { location: 'New York' } },
    verify_update: ->(r) { expect(r.location).to eq 'New York' }
end
