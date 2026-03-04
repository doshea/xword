describe CellsController do
  # Cells are created by Crossword callbacks, not directly; pull them from a crossword.
  let(:user) { create(:user) }
  let(:crossword) { create(:crossword, :smaller, user: user) }
  let(:cell) { crossword.cells.reject(&:is_void).first }

  before { log_in(user) }

  describe 'PATCH #update' do
    # cell_params uses params.require(:cell), so letter must be nested under :cell
    before { patch :update, params: { id: cell.id, cell: { letter: 'Z' } } }

    it { should respond_with(200) }
    it 'updates the cell letter' do
      expect(cell.reload.letter).to eq 'Z'
    end
  end

  describe 'PUT #toggle_void' do
    before { put :toggle_void, params: { id: cell.id } }

    it { should respond_with(200) }
    it 'toggles the void status' do
      # original is false (non-void cell); after toggle it should be true
      expect(cell.reload.is_void).to be true
    end
  end

  describe 'when not logged in' do
    before { session.delete(:user_id) }

    it 'redirects update to account_required' do
      patch :update, params: { id: cell.id, cell: { letter: 'Z' } }
      expect(response.location).to start_with("http://test.host#{account_required_path}")
    end
  end
end
