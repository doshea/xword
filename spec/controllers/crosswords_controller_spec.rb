describe CrosswordsController do
  context 'actions' do
    it { should use_before_action(:ensure_logged_in) }
    it { should use_before_action(:ensure_owner_or_admin) }
  end
end