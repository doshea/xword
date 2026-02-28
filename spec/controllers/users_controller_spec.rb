describe UsersController do
  context 'actions' do
    it { should use_before_action(:ensure_logged_in) }
  end

  describe 'GET #show' do
    let(:user){create(:user)}
    context 'Existing user' do
      before { get :show, params: { id: user.id } }

      it 'has a 200 (OK) status code' do
        expect(response.status).to eq 200
      end
      it 
    end
    context 'Nonexistent user' do
      before { get :show, params: { id: 9999 } }

      it 'has a 302 (redirect) status code' do
        expect(response.status).to eq 302
      end

      it { should redirect_to(error_path(prev: request.original_url))}
    end

    
  end

  describe 'GET #new' do

  end

  describe 'POST #create' do

  end

  describe 'PATCH #update' do

  end

  describe 'GET #account' do

  end

  describe 'GET #forgot_password' do

  end

  describe 'POST #send_password_reset' do

  end

  describe 'GET #reset_password' do

  end

  describe 'POST #resetter' do

  end

  describe 'POST #change_password' do

  end
end