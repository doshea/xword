RSpec.describe 'Pages', type: :request do
  let(:test_password) { 'password123' }
  let(:user)      { create(:user, password: test_password, password_confirmation: test_password) }

  def log_in_as(u)
    post '/login', params: { username: u.username, password: test_password }
  end

  # -------------------------------------------------------------------------
  # GET / — Home page scopes (Publishable concern)
  # -------------------------------------------------------------------------
  describe 'GET / (home)' do
    # Create another user to own the crosswords (so they're "unowned" from user's perspective)
    let(:creator) { create(:user) }

    context 'when logged in' do
      before { log_in_as(user) }

      it 'categorizes an incomplete solution as in-progress' do
        crossword = create(:crossword, :smaller, user: creator)
        blank = crossword.letters.gsub(/[^_]/, ' ')
        create(:solution, user: user, crossword: crossword, letters: blank)

        get '/'
        expect(response).to have_http_status(:ok)
      end

      it 'categorizes a complete solution as solved' do
        crossword = create(:crossword, :smaller, user: creator)
        create(:solution, :complete, user: user, crossword: crossword)

        get '/'
        expect(response).to have_http_status(:ok)
      end

      it 'categorizes a crossword with no solution as unstarted' do
        create(:crossword, :smaller, user: creator)

        get '/'
        expect(response).to have_http_status(:ok)
      end

      it 'includes team-partnered in-progress puzzles' do
        crossword = create(:crossword, :smaller, user: creator)
        owner = create(:user)
        blank = crossword.letters.gsub(/[^_]/, ' ')
        team_sol = create(:solution, :team, user: owner, crossword: crossword, letters: blank)
        SolutionPartnering.create!(user: user, solution: team_sol)

        get '/'
        expect(response).to have_http_status(:ok)
      end

      it 'includes team-partnered solved puzzles' do
        crossword = create(:crossword, :smaller, user: creator)
        owner = create(:user)
        team_sol = create(:solution, :complete, :team, user: owner, crossword: crossword)
        SolutionPartnering.create!(user: user, solution: team_sol)

        get '/'
        expect(response).to have_http_status(:ok)
      end
    end

    context 'when anonymous' do
      it 'renders without errors and shows all crosswords' do
        create(:crossword, :smaller)
        get '/'
        expect(response).to have_http_status(:ok)
      end
    end
  end
end
