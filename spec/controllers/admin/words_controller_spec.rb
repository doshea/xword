describe Admin::WordsController do
  let(:record) { Word.create!(content: 'PUZZLE') }

  it_behaves_like 'admin CRUD controller',
    model_class: Word,
    update_params: { word: { content: 'UPDATED' } },
    verify_update: ->(r) { expect(r.content).to eq 'UPDATED' }
end
