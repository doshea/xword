describe SolutionsController do
  context 'actions' do
    it { should use_before_action(:ensure_owner_or_partner) }
  end
end