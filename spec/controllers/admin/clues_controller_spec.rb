describe Admin::CluesController do
  let(:crossword) { create(:crossword, :smaller) }
  let(:record)    { crossword.cells.find(&:across_clue).across_clue }

  it_behaves_like 'admin CRUD controller',
    model_class: Clue,
    update_params: { clue: { content: 'New clue', difficulty: 2 } },
    verify_update: ->(r) { expect(r.content).to eq 'New clue' }
end
