RSpec.describe 'Sessions', type: :request do
  let(:user) { create(:user, :with_test_password) }
  let(:password) { RequestAuthHelpers::TEST_PASSWORD }

  # -------------------------------------------------------------------------
  # GET /login
  # -------------------------------------------------------------------------
  describe 'GET /login' do
    it 'renders the login page' do
      get '/login'
      expect(response).to have_http_status(:ok)
    end
  end

  # -------------------------------------------------------------------------
  # POST /login
  # -------------------------------------------------------------------------
  describe 'POST /login' do
    context 'with valid credentials' do
      it 'redirects to root and sets signed auth_token cookie' do
        post '/login', params: { username: user.username, password: password }
        expect(response).to redirect_to(root_path)
        expect(cookies[:auth_token]).to be_present
      end
    end

    context 'with wrong password' do
      it 'redirects to login with error flash' do
        post '/login', params: { username: user.username, password: 'WRONGPWD' }
        expect(response).to redirect_to(login_path)
        expect(flash[:error]).to be_present
      end

      it 'does not set an auth_token cookie' do
        post '/login', params: { username: user.username, password: 'WRONGPWD' }
        expect(cookies[:auth_token]).to be_blank
      end
    end

    context 'with unknown username' do
      it 'redirects to login with the same error (no user enumeration)' do
        post '/login', params: { username: 'nonexistent_user', password: password }
        expect(response).to redirect_to(login_path)
        expect(flash[:error]).to be_present
      end
    end

    context 'with remember_me checked' do
      it 'sets a persistent auth_token cookie' do
        post '/login', params: { username: user.username, password: password, remember_me: '1' }
        expect(response).to redirect_to(root_path)
        expect(cookies[:auth_token]).to be_present
      end
    end

    context 'with redirect param' do
      it 'redirects to the specified path after login' do
        post '/login', params: { username: user.username, password: password, redirect: '/faq' }
        expect(response).to redirect_to('/faq')
      end

      it 'blocks open redirects to external URLs' do
        post '/login', params: { username: user.username, password: password, redirect: 'https://evil.com' }
        expect(response).to redirect_to(root_path)
      end

      it 'blocks protocol-relative open redirects' do
        post '/login', params: { username: user.username, password: password, redirect: '//evil.com' }
        expect(response).to redirect_to(root_path)
      end
    end
  end

  # -------------------------------------------------------------------------
  # DELETE /logout
  # -------------------------------------------------------------------------
  describe 'DELETE /logout' do
    it 'clears auth_token cookie and rotates the token' do
      log_in_as(user)
      old_token = user.auth_token

      delete '/logout'

      expect(response).to redirect_to(root_url)
      expect(cookies[:auth_token]).to be_blank
      expect(user.reload.auth_token).not_to eq(old_token)
    end

    it 'handles anonymous logout without error' do
      delete '/logout'
      expect(response).to redirect_to(root_url)
    end
  end
end
