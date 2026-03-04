RSpec.describe 'PuzzleInvites', type: :request do
  let_it_be(:user) { create(:user, :with_test_password) }
  let_it_be(:friend) { create(:user) }
  let_it_be(:crossword) { create(:crossword) }
  let(:team_solution) { create(:solution, crossword: crossword, user: user, team: true, key: 'abc123') }

  before do
    # Stub ActionCable broadcasts
    allow(ActionCable.server).to receive(:broadcast)
    allow(ApplicationController).to receive(:render).and_call_original
  end

  describe 'POST /puzzle_invites' do
    it 'redirects anonymous users' do
      post '/puzzle_invites', params: { solution_id: team_solution.id, user_id: friend.id }
      expect(response).to redirect_to(account_required_path(redirect: '/puzzle_invites'))
    end

    it 'creates notification for friend' do
      log_in_as(user)
      Friendship.create!(user_id: user.id, friend_id: friend.id)

      expect {
        post '/puzzle_invites', params: { solution_id: team_solution.id, user_id: friend.id }
      }.to change(Notification, :count).by(1)

      expect(response).to have_http_status(:ok)
      notification = Notification.last
      expect(notification.user).to eq(friend)
      expect(notification.notification_type).to eq('puzzle_invite')
    end

    it 'returns 422 when not friends' do
      log_in_as(user)
      non_friend = create(:user)

      post '/puzzle_invites', params: { solution_id: team_solution.id, user_id: non_friend.id }
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it 'returns 404 for non-team solution' do
      log_in_as(user)
      Friendship.create!(user_id: user.id, friend_id: friend.id)
      solo_solution = create(:solution, crossword: crossword, user: user, team: false)

      post '/puzzle_invites', params: { solution_id: solo_solution.id, user_id: friend.id }
      expect(response).to have_http_status(:not_found)
    end

    it 'returns 404 for nonexistent solution' do
      log_in_as(user)
      post '/puzzle_invites', params: { solution_id: 999999, user_id: friend.id }
      expect(response).to have_http_status(:not_found)
    end
  end
end
