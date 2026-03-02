describe AdminController do
  let(:admin) { create(:admin) }

  context 'before_actions' do
    it { should use_before_action(:ensure_admin) }
  end

  context 'when not logged in' do
    it 'redirects to unauthorized_path' do
      get :email
      expect(response).to redirect_to(unauthorized_path)
    end
  end

  context 'as admin' do
    before { log_in(admin) }

    describe 'GET #email' do
      before { get :email }
      it { should respond_with(200) }
    end

    describe 'GET #cloning_tank' do
      before { get :cloning_tank }
      it { should respond_with(200) }
    end

    describe 'GET #cheat' do
      before { get :cheat }
      it { should redirect_to(admin_crosswords_path) }
    end

    # -----------------------------------------------------------------------
    # POST #user_search (Turbo Stream)
    # -----------------------------------------------------------------------
    describe 'POST #user_search' do
      before { request.accept = Mime[:turbo_stream].to_s }

      context 'with matching query' do
        let!(:target_user) { create(:user, username: 'searchable') }

        before { post :user_search, params: { query: 'searchable' } }

        it { should respond_with(200) }
        it 'assigns @users' do
          expect(assigns(:users)).to include(target_user)
        end
      end

      context 'with no results' do
        before { post :user_search, params: { query: 'zzzznotfound' } }

        it { should respond_with(200) }
        it 'assigns empty users' do
          expect(assigns(:users)).to be_empty
        end
      end
    end

    # -----------------------------------------------------------------------
    # POST #clone_user
    # -----------------------------------------------------------------------
    describe 'POST #clone_user' do
      let!(:target_user) { create(:user) }

      before { post :clone_user, params: { id: target_user.id } }

      it { should redirect_to(root_path) }
      it 'sets the auth_token cookie' do
        expect(cookies.signed[:auth_token]).to eq target_user.auth_token
      end
    end

    # -----------------------------------------------------------------------
    # GET #manual_nyt
    # -----------------------------------------------------------------------
    describe 'GET #manual_nyt' do
      before { get :manual_nyt }
      it { should respond_with(200) }
    end

    # -----------------------------------------------------------------------
    # POST #create_manual_nyt
    # -----------------------------------------------------------------------
    describe 'POST #create_manual_nyt' do
      context 'with invalid JSON' do
        before { post :create_manual_nyt, params: { nyt_text: 'not valid json {{' } }

        it { should redirect_to(admin_manual_nyt_path) }
        it 'sets an error flash' do
          expect(flash[:error]).to match(/invalid/i)
        end
      end
    end
  end
end
