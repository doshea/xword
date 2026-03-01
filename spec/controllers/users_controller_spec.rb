describe UsersController do
  let(:pw)   { 'testpassword' }
  let(:user) { create(:user, password: pw, password_confirmation: pw) }

  def log_in(u)
    session[:user_id] = u.id
  end

  context 'before_actions' do
    it { should use_before_action(:ensure_logged_in) }
  end

  describe 'GET #show' do
    context 'existing user' do
      before { get :show, params: { id: user.id } }
      it { should respond_with(200) }
    end

    context 'nonexistent user' do
      before { get :show, params: { id: 9999 } }
      it { should respond_with(302) }
      it { should redirect_to(error_path(prev: request.original_url)) }
    end
  end

  describe 'GET #new' do
    before { get :new }
    it { should respond_with(200) }
    it 'assigns a new User' do
      expect(assigns(:user)).to be_a_new(User)
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      before do
        post :create, params: { user: { username: 'newuser', email: 'new@example.com',
                                        password: pw, password_confirmation: pw } }
      end
      it { should redirect_to(root_path) }
      it 'creates the user' do
        expect(User.find_by(username: 'newuser')).to be_present
      end
    end

    context 'with invalid params (mismatched passwords)' do
      before do
        post :create, params: { user: { username: 'newuser', email: 'new@example.com',
                                        password: pw, password_confirmation: 'mismatch' } }
      end
      it { should redirect_to(new_user_path) }
      it 'sets form_errors flash' do
        expect(flash[:form_errors]).to be_present
      end
    end
  end

  describe 'PATCH #update' do
    # update responds with turbo_stream on success (replaces profile pic element)
    before do
      log_in(user)
      request.accept = Mime[:turbo_stream].to_s
      patch :update, params: { id: user.id, user: { first_name: 'Dylan' } }
    end

    it { should respond_with(200) }
    it 'updates the user attribute' do
      expect(user.reload.first_name).to eq 'Dylan'
    end
  end

  describe 'GET #account' do
    context 'when logged in' do
      before { log_in(user); get :account }
      it { should respond_with(200) }
      it 'assigns @user as current user' do
        expect(assigns(:user)).to eq user
      end
    end

    context 'when anonymous' do
      before { get :account }
      it { should redirect_to(account_required_path) }
    end
  end

  describe 'GET #forgot_password' do
    before { get :forgot_password }
    it { should respond_with(200) }
  end

  describe 'POST #send_password_reset' do
    # Renders send_password_reset.turbo_stream.erb; stubs mailer to avoid sending real email.
    before do
      request.accept = Mime[:turbo_stream].to_s
      allow(UserMailer).to receive_message_chain(:reset_password_email, :deliver_now)
      post :send_password_reset, params: { email: user.email }
    end

    it { should respond_with(200) }
    it 'delivers the reset password email' do
      # Mailer should have been called (stubbed above); confirm no exception was raised.
      expect(UserMailer).to have_received(:reset_password_email)
    end
  end

  describe 'POST #resetter' do
    # Rails 8.1: password_reset_token is a signed token derived from password_salt.
    # Use user.password_reset_token directly — no DB storage required.
    let(:token) { user.password_reset_token }

    context 'with valid token and matching passwords' do
      before do
        post :resetter, params: { password_reset_token: token,
                                  new_password: 'newpass123',
                                  new_password_confirmation: 'newpass123' }
      end
      it { should redirect_to(account_users_path) }
    end

    context 'with mismatched passwords (validation failure)' do
      before do
        request.accept = Mime[:turbo_stream].to_s
        post :resetter, params: { password_reset_token: token,
                                  new_password: 'newpass123',
                                  new_password_confirmation: 'different' }
      end
      it { should respond_with(200) }  # renders password_errors.turbo_stream.erb
    end

    context 'with invalid token' do
      before { post :resetter, params: { password_reset_token: 'bogustoken' } }
      it { should redirect_to(reset_password_users_path('bogustoken')) }
    end
  end

  describe 'POST #change_password' do
    before { log_in(user) }

    context 'with correct old password and valid new password' do
      before do
        post :change_password, params: { old_password: pw,
                                         new_password: 'newpass123',
                                         new_password_confirmation: 'newpass123' }
      end
      it { should redirect_to(account_users_path) }
    end

    context 'with wrong old password' do
      # renders wrong_password.turbo_stream.erb
      before do
        request.accept = Mime[:turbo_stream].to_s
        post :change_password, params: { old_password: 'WRONG',
                                         new_password: 'newpass123',
                                         new_password_confirmation: 'newpass123' }
      end
      it { should respond_with(200) }
    end

    context 'with mismatched new passwords (validation failure)' do
      # renders password_errors.turbo_stream.erb
      before do
        request.accept = Mime[:turbo_stream].to_s
        post :change_password, params: { old_password: pw,
                                         new_password: 'newpass123',
                                         new_password_confirmation: 'different' }
      end
      it { should respond_with(200) }
    end
  end
end
