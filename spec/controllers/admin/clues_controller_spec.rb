describe Admin::CluesController do

  subject {Admin::CluesController}
  it {should < ApplicationController}

  # All methods in this controller require admin_status
  # therefore they must log in as admin
  before do
    @current_user = create(:admin)
    session[:user_id] = @current_user.id
  end

  describe 'collection' do
    describe 'GET #index' do
      it '' do

      end

      it 'renders the :index view' do
        get :index
        response.should render_template :index
      end
    end

  end

  describe 'member' do

  end

end