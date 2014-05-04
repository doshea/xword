describe AdminController do
  context 'actions' do
    it { should use_before_action(:ensure_admin) }
  end
end