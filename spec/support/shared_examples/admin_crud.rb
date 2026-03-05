RSpec.shared_examples 'admin CRUD controller' do |opts = {}|
  let(:admin) { create(:admin) }
  let(:index_path) { send("admin_#{described_class.controller_name}_path") }

  # Host spec must define: let(:record) { ... }

  context 'before_actions' do
    it { is_expected.to use_before_action(:ensure_admin) }
  end

  context 'when not logged in' do
    it 'redirects to unauthorized_path' do
      get :index
      expect(response).to redirect_to(unauthorized_path)
    end
  end

  context 'as admin' do
    before { log_in(admin) }

    describe 'GET #index' do
      before { get :index }
      it { is_expected.to respond_with(200) }
    end

    describe 'GET #edit' do
      before { get :edit, params: { id: record.id } }
      it { is_expected.to respond_with(200) }
    end

    if opts[:update_params]
      describe 'PATCH #update' do
        before { patch :update, params: { id: record.id, **opts[:update_params] } }
        it { is_expected.to redirect_to(index_path) }
        it 'updates the record' do
          instance_exec(record.reload, &opts[:verify_update])
        end
      end
    end

    describe 'DELETE #destroy' do
      before { record }
      it 'destroys the record' do
        expect { delete :destroy, params: { id: record.id } }
          .to change(opts[:model_class], :count).by(-1)
      end
      it 'redirects to index' do
        delete :destroy, params: { id: record.id }
        expect(response).to redirect_to(index_path)
      end
    end
  end
end
