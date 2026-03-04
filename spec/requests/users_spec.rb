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
      expect(response.body).to include('Not Friends')
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
  # POST /users (create / signup)
  # -------------------------------------------------------------------------
  describe 'POST /users (signup)' do
    it 'creates a user and redirects to root' do
      expect {
        post '/users', params: { user: { username: 'newuser', email: 'new@example.com', password: 'secret123', password_confirmation: 'secret123' } }
      }.to change(User, :count).by(1)
      expect(response).to redirect_to(root_path)
    end

    it 'redirects back with errors for invalid data' do
      post '/users', params: { user: { username: '', email: '', password: 'x', password_confirmation: 'y' } }
      expect(response).to redirect_to(new_user_path)
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

end
