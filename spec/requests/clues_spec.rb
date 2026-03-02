RSpec.describe 'Clues', type: :request do
  let(:owner)    { create(:user, :with_test_password) }
  let(:outsider) { create(:user, :with_test_password) }
  let(:crossword) { create(:crossword, :smaller, user: owner) }
  let(:clue)      { crossword.cells.find(&:across_clue).across_clue }

  # -------------------------------------------------------------------------
  # PATCH /clues/:id — authorization
  # -------------------------------------------------------------------------
  describe 'PATCH /clues/:id authorization' do
    context 'as the crossword owner' do
      before { log_in_as(owner) }

      it 'updates the clue content' do
        patch "/clues/#{clue.id}", params: { clue: { content: 'New clue text' } }
        expect(response).to have_http_status(:ok)
        expect(clue.reload.content).to eq 'New clue text'
      end
    end

    context 'as a different logged-in user (not the crossword owner)' do
      before { log_in_as(outsider) }

      it 'returns 403 and does not modify the clue' do
        original_content = clue.content
        patch "/clues/#{clue.id}", params: { clue: { content: 'Hacked clue' } }
        expect(response).to have_http_status(:forbidden)
        expect(clue.reload.content).to eq original_content
      end
    end

    context 'as an anonymous user' do
      it 'redirects to account_required' do
        patch "/clues/#{clue.id}", params: { clue: { content: 'Nope' } }
        expect(response).to redirect_to(account_required_path)
      end
    end

    context 'as an admin (not the owner)' do
      let(:admin) { create(:admin, :with_test_password) }

      before { log_in_as(admin) }

      it 'allows updating the clue' do
        patch "/clues/#{clue.id}", params: { clue: { content: 'Admin edit' } }
        expect(response).to have_http_status(:ok)
        expect(clue.reload.content).to eq 'Admin edit'
      end
    end
  end
end
