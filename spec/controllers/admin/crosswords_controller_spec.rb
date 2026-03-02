describe Admin::CrosswordsController do
  let(:record) { create(:crossword, :smaller) }

  it_behaves_like 'admin CRUD controller',
    model_class: Crossword,
    update_params: { crossword: { title: 'New Title' } },
    verify_update: ->(r) { expect(r.title).to eq 'New Title' }
end
