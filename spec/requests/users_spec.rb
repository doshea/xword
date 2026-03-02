RSpec.describe 'Users', type: :request do
  let(:test_password) { 'password123' }
  let(:user) { create(:user, password: test_password, password_confirmation: test_password) }

  def log_in_as(u)
    post '/login', params: { username: u.username, password: test_password }
  end

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

end
