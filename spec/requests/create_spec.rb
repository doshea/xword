RSpec.describe 'Create Dashboard', type: :request do
  let(:user) { create(:user, :with_test_password) }

  # ---------------------------------------------------------------------------
  # GET /create/dashboard
  # ---------------------------------------------------------------------------
  describe 'GET /create/dashboard' do
    context 'when logged out' do
      it 'redirects to account required page' do
        get '/create/dashboard'
        expect(response).to redirect_to(account_required_path(redirect: '/create/dashboard'))
      end
    end

    context 'when logged in with puzzles' do
      before { log_in_as(user) }

      it 'renders the dashboard' do
        create(:unpublished_crossword, user: user, title: 'My Draft')
        create(:crossword, user: user)

        get '/create/dashboard'
        expect(response).to have_http_status(:ok)
        expect(response.body).to include('My Draft')
        expect(response.body).to include('Unpublished')
        expect(response.body).to include('Published')
      end

      it 'shows unpublished puzzles in most-recently-edited order' do
        old_puzzle = create(:unpublished_crossword, user: user, title: 'Old Draft')
        new_puzzle = create(:unpublished_crossword, user: user, title: 'New Draft')
        old_puzzle.update!(updated_at: 2.days.ago)

        get '/create/dashboard'
        body = response.body
        expect(body.index('New Draft')).to be < body.index('Old Draft')
      end
    end

    context 'when logged in with no puzzles' do
      before { log_in_as(user) }

      it 'renders the empty state' do
        get '/create/dashboard'
        expect(response).to have_http_status(:ok)
        expect(response.body).to include('No puzzles in progress')
        expect(response.body).to include('New Puzzle')
      end

      it 'does not show published section when user has no published puzzles' do
        get '/create/dashboard'
        expect(response.body).not_to include('Published')
      end
    end
  end
end
