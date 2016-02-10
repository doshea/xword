describe PagesController do
  context 'anonymous' do
    context 'GET #home' do
      before {get :home}

      it {should respond_with(:success)}
    end
  end
  context 'logged_in' do
    before {get :home}
    it {should respond_with(:success)}
  end
end