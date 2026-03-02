RSpec.describe 'Cells', type: :request do
  let(:user)      { create(:user, password: RequestAuthHelpers::TEST_PASSWORD, password_confirmation: RequestAuthHelpers::TEST_PASSWORD) }
  let(:crossword) { create(:crossword, :smaller, user: user) }

  # -------------------------------------------------------------------------
  # PUT /cells/:id/toggle_void — cascade behavior
  # -------------------------------------------------------------------------
  describe 'PUT /cells/:id/toggle_void (cascade effects)' do
    before { log_in_as(user) }

    context 'toggling a non-void cell to void' do
      let(:cell) { crossword.cells.reject(&:is_void).first }

      before do
        # Give the cell a letter so we can verify it gets cleared
        cell.update!(letter: 'Z')
      end

      it 'clears the letter when becoming void' do
        put "/cells/#{cell.id}/toggle_void"
        expect(response).to have_http_status(:ok)
        expect(cell.reload.letter).to be_nil
      end

      it 'sets is_void to true' do
        put "/cells/#{cell.id}/toggle_void"
        expect(cell.reload.is_void).to be true
      end

      it 'updates is_across_start on the cell to the right' do
        right_cell = cell.right_cell
        if right_cell
          old_across_start = right_cell.is_across_start
          put "/cells/#{cell.id}/toggle_void"
          # After making this cell void, the cell to the right may become an across-start
          right_cell.reload
          # The right cell should now be an across-start (if it has a non-void cell to its right)
          expect(right_cell.is_across_start).not_to eq(old_across_start) if right_cell.right_cell && !right_cell.right_cell.is_void
        end
      end

      it 'updates is_down_start on the cell below' do
        below_cell = cell.below_cell
        if below_cell
          old_down_start = below_cell.is_down_start
          put "/cells/#{cell.id}/toggle_void"
          below_cell.reload
          # The below cell should now be a down-start (if it has a non-void cell below it)
          expect(below_cell.is_down_start).not_to eq(old_down_start) if below_cell.below_cell && !below_cell.below_cell.is_void
        end
      end
    end

    context 'toggling a void cell back to non-void' do
      it 'sets is_void to false' do
        cell = crossword.cells.reject(&:is_void).first
        # First make it void
        put "/cells/#{cell.id}/toggle_void"
        expect(cell.reload.is_void).to be true

        # Then toggle back
        put "/cells/#{cell.id}/toggle_void"
        expect(cell.reload.is_void).to be false
      end
    end
  end
end
