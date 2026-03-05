RSpec.describe 'Users', type: :request do
  let(:user) { create(:user, :with_test_password) }

  # -------------------------------------------------------------------------
  # GET /users/reset_password/:token
  # -------------------------------------------------------------------------
  describe 'GET /users/reset_password/:token' do
    it 'renders the reset password form with a valid token' do
      token = user.password_reset_token
      get "/users/reset_password/#{token}"
      expect(response).to have_http_status(:ok)
    end

    it 'renders the form even with an invalid token (no crash)' do
      get '/users/reset_password/bogus_token_value'
      expect(response).to have_http_status(:ok)
    end
  end

  # -------------------------------------------------------------------------
  # GET /users/:id (show)
  # -------------------------------------------------------------------------
  describe 'GET /users/:id' do
    it 'renders the user profile page' do
      get "/users/#{user.id}"
      expect(response).to have_http_status(:ok)
    end

    it 'redirects to error page for nonexistent user' do
      get '/users/999999'
      expect(response).to have_http_status(:redirect)
      expect(response.location).to include('/error')
    end

    it 'renders profile with comments, replies, and crosswords' do
      crossword = create(:crossword, user: user)
      comment   = create(:comment, user: user, crossword: crossword)
      reply     = create(:comment, user: user, crossword: nil, base_comment: comment)

      get "/users/#{user.id}"
      expect(response).to have_http_status(:ok)
      expect(response.body).to include(comment.content)
      expect(response.body).to include(reply.content)
      expect(response.body).to include(crossword.title)
    end

    it 'shows friendship status when viewed by a logged-in user' do
      viewer = create(:user, :with_test_password)
      log_in_as(viewer)

      get "/users/#{user.id}"
      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Add Friend')
    end

    it 'hides "In Progress" stat from other users' do
      viewer = create(:user, :with_test_password)
      log_in_as(viewer)

      get "/users/#{user.id}"
      expect(response.body).not_to include('In Progress')
    end

    it 'shows "In Progress" stat on own profile' do
      log_in_as(user)

      get "/users/#{user.id}"
      expect(response.body).to include('In Progress')
    end

    it 'shows "Edit Profile" link on own profile' do
      log_in_as(user)

      get "/users/#{user.id}"
      expect(response.body).to include('Edit Profile')
    end

    it 'does not show "Edit Profile" link on another user profile' do
      viewer = create(:user, :with_test_password)
      log_in_as(viewer)

      get "/users/#{user.id}"
      expect(response.body).not_to include('Edit Profile')
    end

    it 'displays location when present' do
      user.update!(location: 'Portland, OR')

      get "/users/#{user.id}"
      expect(response.body).to include('Portland, OR')
    end
  end

  # -------------------------------------------------------------------------
  # PATCH /users/:id (update)
  # -------------------------------------------------------------------------
  describe 'PATCH /users/:id' do
    context 'when user does not exist' do
      before { log_in_as(user) }

      it 'redirects to error page' do
        patch "/users/0", params: { user: { first_name: 'Test' } }
        expect(response).to have_http_status(:redirect)
        expect(response.location).to include('/error')
      end
    end
  end

  # -------------------------------------------------------------------------
  # GET /users/new (signup page)
  # -------------------------------------------------------------------------
  describe 'GET /users/new' do
    it 'renders the signup page' do
      get '/users/new'
      expect(response).to have_http_status(:ok)
    end

    it 'redirects to root when already logged in' do
      log_in_as(user)
      get '/users/new'
      expect(response).to redirect_to(root_path)
    end
  end

  # -------------------------------------------------------------------------
  # POST /users (create / signup)
  # -------------------------------------------------------------------------
  describe 'POST /users (signup)' do
    it 'creates a user and redirects to root' do
      expect {
        post '/users', params: { user: { username: 'newuser', email: 'new@example.com', password: 'secret123', password_confirmation: 'secret123' } }
      }.to change(User, :count).by(1)
      expect(response).to redirect_to(root_path)
    end

    it 'redirects to the specified path after signup' do
      expect {
        post '/users', params: { user: { username: 'newuser2', email: 'new2@example.com', password: 'secret123', password_confirmation: 'secret123' }, redirect: '/faq' }
      }.to change(User, :count).by(1)
      expect(response).to redirect_to('/faq')
    end

    it 'blocks open redirects on signup' do
      post '/users', params: { user: { username: 'newuser3', email: 'new3@example.com', password: 'secret123', password_confirmation: 'secret123' }, redirect: 'https://evil.com' }
      expect(response).to redirect_to(root_path)
    end

    it 'redirects back with errors for invalid data' do
      post '/users', params: { user: { username: '', email: '', password: 'x', password_confirmation: 'y' } }
      expect(response).to redirect_to(new_user_path)
    end

    it 'preserves redirect param on validation failure' do
      post '/users', params: { user: { username: '', email: '', password: 'x', password_confirmation: 'y' }, redirect: '/crosswords/5' }
      expect(response).to redirect_to(new_user_path(redirect: '/crosswords/5'))
    end
  end

  # -------------------------------------------------------------------------
  # GET /users/forgot_password
  # -------------------------------------------------------------------------
  describe 'GET /users/forgot_password' do
    it 'renders the forgot password page' do
      get '/users/forgot_password'
      expect(response).to have_http_status(:ok)
    end
  end

  # -------------------------------------------------------------------------
  # POST /users/send_password_reset
  # -------------------------------------------------------------------------
  describe 'POST /users/send_password_reset' do
    before do
      allow(UserMailer).to receive_message_chain(:reset_password_email, :deliver_now)
    end

    it 'redirects with success flash even for unknown email (no user enumeration)' do
      post '/users/send_password_reset', params: { email: 'unknown@example.com' }
      expect(response).to redirect_to(forgot_password_users_path)
    end

    it 'redirects with success flash for a known user' do
      post '/users/send_password_reset', params: { email: user.email }
      expect(response).to redirect_to(forgot_password_users_path)
    end
  end

  # -------------------------------------------------------------------------
  # POST /users/resetter (reset password submission)
  # -------------------------------------------------------------------------
  describe 'POST /users/resetter' do
    it 'redirects with success flash on valid reset' do
      token = user.password_reset_token
      post '/users/resetter', params: {
        password_reset_token: token,
        new_password: 'newpass1234',
        new_password_confirmation: 'newpass1234'
      }
      expect(response).to redirect_to(account_users_path)
      expect(flash[:success]).to include('Password updated')
    end

    it 'redirects to forgot page when token is invalid' do
      post '/users/resetter', params: {
        password_reset_token: 'bogus',
        new_password: 'newpass1234',
        new_password_confirmation: 'newpass1234'
      }
      expect(response).to redirect_to(forgot_password_users_path)
    end

    it 'returns turbo stream with error container on validation failure' do
      token = user.password_reset_token
      post '/users/resetter', params: {
        password_reset_token: token,
        new_password: 'short',
        new_password_confirmation: 'mismatch'
      }, headers: { 'Accept' => Mime[:turbo_stream].to_s }
      expect(response).to have_http_status(:ok)
      expect(response.body).to include('id="password-errors"')
      expect(response.body).to include('xw-alert--error')
    end
  end

  # -------------------------------------------------------------------------
  # POST /users/change_password (turbo stream errors)
  # -------------------------------------------------------------------------
  describe 'POST /users/change_password' do
    before { log_in_as(user) }

    it 'returns turbo stream with error container for wrong old password' do
      post '/users/change_password', params: {
        old_password: 'wrongpassword',
        new_password: 'newpass1234',
        new_password_confirmation: 'newpass1234'
      }, headers: { 'Accept' => Mime[:turbo_stream].to_s }
      expect(response).to have_http_status(:ok)
      expect(response.body).to include('id="password-errors"')
      expect(response.body).to include('old password is incorrect')
    end

    it 'returns turbo stream with error container for validation failure' do
      post '/users/change_password', params: {
        old_password: RequestAuthHelpers::TEST_PASSWORD,
        new_password: 'x',
        new_password_confirmation: 'y'
      }, headers: { 'Accept' => Mime[:turbo_stream].to_s }
      expect(response).to have_http_status(:ok)
      expect(response.body).to include('id="password-errors"')
      expect(response.body).to include('xw-alert--error')
    end
  end

  # -------------------------------------------------------------------------
  # Auth token rotation — password change invalidates old token
  # -------------------------------------------------------------------------
  describe 'auth token rotation on password change' do
    it 'rotates auth_token after changing password' do
      log_in_as(user)
      old_token = user.reload.auth_token

      post '/users/change_password', params: {
        old_password: RequestAuthHelpers::TEST_PASSWORD,
        new_password: 'newsecret99',
        new_password_confirmation: 'newsecret99'
      }

      expect(user.reload.auth_token).not_to eq old_token
    end
  end

  # -------------------------------------------------------------------------
  # Auth token rotation — logout invalidates old token
  # -------------------------------------------------------------------------
  describe 'auth token rotation on logout' do
    it 'rotates auth_token after logging out' do
      log_in_as(user)
      old_token = user.reload.auth_token

      delete '/logout'

      expect(user.reload.auth_token).not_to eq old_token
    end
  end

  # -------------------------------------------------------------------------
  # Password bypass prevention — profile update must not accept password
  # -------------------------------------------------------------------------
  describe 'PATCH /users/:id (password bypass prevention)' do
    before { log_in_as(user) }

    it 'does not allow password change via profile update' do
      old_digest = user.reload.password_digest

      patch "/users/#{user.id}", params: {
        user: { first_name: 'Hacker', password: 'pwned123', password_confirmation: 'pwned123' }
      }

      user.reload
      expect(user.first_name).to eq 'Hacker'
      expect(user.password_digest).to eq old_digest
    end
  end

  # -------------------------------------------------------------------------
  # PATCH /users/:id — email and username update
  # -------------------------------------------------------------------------
  describe 'PATCH /users/:id (email and username update)' do
    before { log_in_as(user) }

    it 'updates email successfully' do
      patch "/users/#{user.id}", params: { user: { email: 'newemail@example.com' } }
      expect(user.reload.email).to eq('newemail@example.com')
    end

    it 'updates username successfully' do
      patch "/users/#{user.id}", params: { user: { username: 'newname1234' } }
      expect(user.reload.username).to eq('newname1234')
    end

    it 'shows error for duplicate email' do
      other = create(:user)
      patch "/users/#{user.id}", params: { user: { email: other.email } }
      expect(response).to redirect_to(account_users_path)
      follow_redirect!
      expect(response.body).to include('already been taken')
    end

    it 'shows error for duplicate username' do
      other = create(:user)
      patch "/users/#{user.id}", params: { user: { username: other.username } }
      expect(response).to redirect_to(account_users_path)
      follow_redirect!
      expect(response.body).to include('already been taken')
    end
  end

  # -------------------------------------------------------------------------
  # PATCH /users/:id — notification preferences
  # -------------------------------------------------------------------------
  describe 'PATCH /users/:id (notification preferences)' do
    before { log_in_as(user) }

    it 'saves notification preferences' do
      patch "/users/#{user.id}", params: {
        user: { notification_preferences: { 'friend_request' => '0', 'comment_reply' => '1' } }
      }
      user.reload
      expect(user.notification_muted?('friend_request')).to be true
      expect(user.notification_muted?('comment_reply')).to be false
    end
  end

  # -------------------------------------------------------------------------
  # DELETE /users/delete_account
  # -------------------------------------------------------------------------
  describe 'DELETE /users/delete_account' do
    it 'anonymizes the user and redirects to root' do
      log_in_as(user)
      delete '/users/delete_account'
      expect(response).to redirect_to(root_path)

      user.reload
      expect(user.deleted?).to be true
      expect(user.display_name).to eq('[Deleted Account]')
      expect(user.first_name).to be_nil
      expect(user.password_digest).to be_nil
    end

    it 'cleans up friendships' do
      log_in_as(user)
      friend = create(:user)
      Friendship.create!(user_id: user.id, friend_id: friend.id)

      expect {
        delete '/users/delete_account'
      }.to change(Friendship, :count).by(-1)
    end

    it 'preserves crosswords created by the user' do
      log_in_as(user)
      crossword = create(:crossword, user: user)

      delete '/users/delete_account'

      expect(crossword.reload).to be_present
      expect(crossword.user_id).to eq(user.id)
    end

    it 'redirects unauthenticated users' do
      delete '/users/delete_account'
      expect(response).to redirect_to(account_required_path(redirect: '/users/delete_account'))
    end
  end

  # -------------------------------------------------------------------------
  # GET /users/:id — deleted user profile redirect
  # -------------------------------------------------------------------------
  describe 'GET /users/:id (deleted user)' do
    it 'redirects to root when user is deleted' do
      user.update_columns(deleted_at: Time.current)
      get "/users/#{user.id}"
      expect(response).to redirect_to(root_path)
    end
  end

  # -------------------------------------------------------------------------
  # POST /login — deleted user cannot log in
  # -------------------------------------------------------------------------
  describe 'POST /login (deleted user)' do
    it 'rejects login for deleted user' do
      user.update_columns(deleted_at: Time.current)
      post '/login', params: { username: user.username, password: RequestAuthHelpers::TEST_PASSWORD }
      expect(response).to redirect_to(login_path)
    end
  end

end
