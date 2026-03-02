describe AccountController do
  let(:pw)   { 'testpassword' }
  let(:user) { create(:full_user, password: pw, password_confirmation: pw) }

  context 'before_actions' do
    it { should use_before_action(:ensure_logged_in) }
  end

  describe 'GET #show' do
    context 'when logged in' do
      # AccountController#show has no template (app/views/account/show.html.haml
      # does not exist); the real account page is at /users/account.
      it 'raises MissingExactTemplate' do
        log_in(user)
        expect { get :show }.to raise_error(ActionController::MissingExactTemplate)
      end
    end

    context 'when anonymous' do
      before { get :show }
      it { should redirect_to(account_required_path) }
    end
  end

  describe 'PATCH #update' do
    context 'when logged in' do
      before do
        log_in(user)
        patch :update, params: { user: { first_name: 'Updated' } }
      end
      it { should redirect_to(account_path) }
      it 'updates the user attribute' do
        expect(user.reload.first_name).to eq 'Updated'
      end
    end

    context 'when anonymous' do
      before { patch :update, params: { user: { first_name: 'Updated' } } }
      it { should redirect_to(account_required_path) }
    end
  end

  describe 'PATCH #change_password' do
    context 'when logged in' do
      context 'with correct old password' do
        before do
          log_in(user)
          patch :change_password, params: { old_password: pw,
                                            user: { password: 'newpass123',
                                                    password_confirmation: 'newpass123' } }
        end
        it { should redirect_to(account_path) }
        it 'updates the password' do
          expect(user.reload.authenticate('newpass123')).to be_truthy
        end
      end

      context 'with wrong old password' do
        before do
          log_in(user)
          patch :change_password, params: { old_password: 'WRONG',
                                            user: { password: 'newpass123',
                                                    password_confirmation: 'newpass123' } }
        end
        it { should redirect_to(account_path) }
        it 'does not update the password' do
          expect(user.reload.authenticate(pw)).to be_truthy
        end
      end
    end

    context 'when anonymous' do
      before { patch :change_password, params: { old_password: pw } }
      it { should redirect_to(account_required_path) }
    end
  end

  describe 'GET #verify' do
    context 'with valid verification token' do
      before { get :verify, params: { verification_token: user.verification_token } }
      it { should redirect_to(account_verified_path) }
      it 'marks the user as verified' do
        expect(user.reload.verified).to be true
      end
      it 'sets the auth cookie' do
        expect(cookies.signed[:auth_token]).to eq user.auth_token
      end
    end

    context 'with invalid verification token' do
      before { get :verify, params: { verification_token: 'bogus' } }
      it { should redirect_to(root_path) }
    end
  end

  describe 'GET #verified' do
    # AccountController#verified has no template (app/views/account/verified.html.haml
    # does not exist); verify action redirects to account_verified_path which hits this.
    it 'raises MissingExactTemplate' do
      expect { get :verified }.to raise_error(ActionController::MissingExactTemplate)
    end
  end
end
