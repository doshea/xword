describe CluesController do
  # Clues are created by Crossword callbacks; pull from a crossword's cells.
  let(:crossword) { create(:crossword, :smaller) }
  let(:clue) { crossword.cells.find(&:across_clue).across_clue }

  describe 'GET #show' do
    before { get :show, params: { id: clue.id } }

    it { should respond_with(200) }
    it 'assigns @clue' do
      expect(assigns(:clue)).to eq clue
    end
  end

  describe 'PATCH #update' do
    # clue_params uses params.require(:clue), so content must be nested under :clue
    before { patch :update, params: { id: clue.id, clue: { content: 'Updated clue content' } } }

    it { should respond_with(200) }
    it 'updates the clue content' do
      expect(clue.reload.content).to eq 'Updated clue content'
    end
  end
end