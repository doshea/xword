require 'spec_helper'

describe CreateController do
  render_views

  describe 'GET #dashboard' do
    context 'as a logged-in user with unpublished crosswords' do
      let(:user) { create(:user) }

      before do
        session[:user_id] = user.id
        # Create an unpublished crossword for this user
        UnpublishedCrossword.create!(
          title: 'Test Puzzle',
          rows: 5,
          cols: 5,
          user_id: user.id
        )
      end

      it 'renders the dashboard without error' do
        get :dashboard
        expect(response).to have_http_status(:ok)
      end
    end

    context 'as an anonymous user' do
      it 'renders the dashboard without error' do
        get :dashboard
        expect(response).to have_http_status(:ok)
      end
    end
  end
end
