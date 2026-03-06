RSpec.describe 'Admin form pages', type: :request do
  let_it_be(:admin) { create(:user, :with_test_password, is_admin: true) }

  before { log_in_as(admin) }

  # ---------------------------------------------------------------------------
  # Shared examples — every admin edit page should render with BEM form classes
  # ---------------------------------------------------------------------------
  shared_examples 'a styled admin edit page' do
    it 'renders successfully' do
      expect(response).to have_http_status(:ok)
    end

    it 'contains BEM form structure' do
      expect(response.body).to include('xw-admin-form')
      expect(response.body).to include('xw-label')
    end
  end

  # ---------------------------------------------------------------------------
  # Users
  # ---------------------------------------------------------------------------
  describe 'GET /admin/users/:id/edit' do
    let!(:user) { create(:user) }

    before { get "/admin/users/#{user.id}/edit" }

    it_behaves_like 'a styled admin edit page'

    it 'contains user-specific fields' do
      expect(response.body).to include('xw-input')
      expect(response.body).to include('xw-checkbox')
    end
  end

  describe 'PATCH /admin/users/:id with invalid data' do
    let!(:user) { create(:user) }

    it 'renders edit with errors when username is blank' do
      patch "/admin/users/#{user.id}", params: { user: { username: '' } }

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include('xw-alert--error')
    end
  end

  # ---------------------------------------------------------------------------
  # Crosswords
  # ---------------------------------------------------------------------------
  describe 'GET /admin/crosswords/:id/edit' do
    let!(:crossword) { create(:crossword) }

    before { get "/admin/crosswords/#{crossword.id}/edit" }

    it_behaves_like 'a styled admin edit page'

    it 'contains crossword-specific fields' do
      expect(response.body).to include('xw-textarea')
      expect(response.body).to include('xw-checkbox')
    end
  end

  # ---------------------------------------------------------------------------
  # Words
  # ---------------------------------------------------------------------------
  describe 'GET /admin/words/:id/edit' do
    let!(:word) { Word.create!(content: 'TESTWORD') }

    before { get "/admin/words/#{word.id}/edit" }

    it_behaves_like 'a styled admin edit page'
  end

  # ---------------------------------------------------------------------------
  # Clues
  # ---------------------------------------------------------------------------
  describe 'GET /admin/clues/:id/edit' do
    let!(:crossword) { create(:crossword) }
    let!(:clue) { crossword.cells.find(&:across_clue)&.across_clue }

    before { get "/admin/clues/#{clue.id}/edit" }

    it_behaves_like 'a styled admin edit page'
  end

  # ---------------------------------------------------------------------------
  # Solutions
  # ---------------------------------------------------------------------------
  describe 'GET /admin/solutions/:id/edit' do
    let!(:solution) { create(:solution, user: admin, crossword: create(:crossword)) }

    before { get "/admin/solutions/#{solution.id}/edit" }

    it_behaves_like 'a styled admin edit page'

    it 'contains solution-specific fields' do
      expect(response.body).to include('xw-checkbox')
    end
  end

  # ---------------------------------------------------------------------------
  # Comments
  # ---------------------------------------------------------------------------
  describe 'GET /admin/comments/:id/edit' do
    let!(:comment) { create(:comment) }

    before { get "/admin/comments/#{comment.id}/edit" }

    it_behaves_like 'a styled admin edit page'

    it 'contains comment-specific fields' do
      expect(response.body).to include('xw-checkbox')
    end
  end

  # ---------------------------------------------------------------------------
  # Non-admin access
  # ---------------------------------------------------------------------------
  describe 'non-admin access' do
    let(:regular_user) { create(:user, :with_test_password) }

    it 'redirects non-admin users' do
      log_in_as(regular_user)
      get "/admin/users/#{regular_user.id}/edit"
      expect(response).to redirect_to(unauthorized_path)
    end
  end
end
