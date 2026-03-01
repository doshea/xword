describe SessionsController do
  # Use an explicit password so we can submit it in POST #create tests
  let(:pw)   { 'testpassword' }
  let(:user) { create(:user, password: pw, password_confirmation: pw) }

  describe 'GET #new' do
    before { get :new }
    it { should respond_with(200) }
  end

  describe 'POST #create' do
    context 'with valid credentials' do
      before { post :create, params: { username: user.username, password: pw } }

      it { should redirect_to(root_path) }
      it 'sets the signed auth_token cookie' do
        expect(cookies.signed[:auth_token]).to eq user.auth_token
      end
    end

    context 'with wrong password' do
      before { post :create, params: { username: user.username, password: 'WRONGPWD' } }

      it { should redirect_to(login_path) }
      it 'sets an error flash' do
        expect(flash[:error]).to be_present
      end
      it 'does not set an auth_token cookie' do
        expect(cookies.signed[:auth_token]).to be_nil
      end
    end

    context 'with unknown username' do
      before { post :create, params: { username: 'nobody_at_all', password: pw } }

      it { should redirect_to(login_path) }
    end

    context 'with remember_me checked' do
      before { post :create, params: { username: user.username, password: pw, remember_me: '1' } }

      it 'sets the auth_token cookie' do
        expect(cookies.signed[:auth_token]).to eq user.auth_token
      end
    end
  end

  describe 'DELETE #destroy' do
    before do
      # Simulate a logged-in session, then log out
      cookies.signed[:auth_token] = user.auth_token
      delete :destroy
    end

    it { should redirect_to(root_url) }
    it 'removes the auth_token cookie' do
      expect(cookies[:auth_token]).to be_nil
    end
  end
end
