RSpec.describe 'UnpublishedCrosswords', type: :request do
  let(:owner)  { create(:user, :with_test_password) }
  let(:other)  { create(:user, :with_test_password) }

  # Build a publishable UCW: 4x4 grid, all letters filled, a couple of voids, clues on start cells
  def create_publishable_ucw(user:)
    ucw = create(:unpublished_crossword, rows: 4, cols: 4, user: user)

    # Fill all 16 cells with letters; make positions 3 and 12 (0-based) void (nil)
    letters = %w[A B C D E F G H I J K L M N O P]
    letters[3]  = nil  # void at row 1, col 4
    letters[12] = nil  # void at row 4, col 1
    ucw.update!(letters: letters)

    # Set across/down clues on positions that will be start cells
    across_clues = [nil] * 16
    down_clues   = [nil] * 16
    across_clues[0]  = 'First across'
    across_clues[4]  = 'Second across'
    down_clues[0]    = 'First down'
    down_clues[1]    = 'Second down'
    ucw.update!(across_clues: across_clues, down_clues: down_clues)

    ucw
  end

  # -----------------------------------------------------------------------
  # POST /unpublished_crosswords (create)
  # -----------------------------------------------------------------------
  describe 'POST /unpublished_crosswords' do
    context 'when logged in' do
      before { log_in_as(owner) }

      it 'creates a puzzle and redirects to edit on success' do
        expect {
          post '/unpublished_crosswords',
               params: { unpublished_crossword: { title: 'My Puzzle', rows: 5, cols: 5 } }
        }.to change(UnpublishedCrossword, :count).by(1)

        ucw = UnpublishedCrossword.last
        expect(response).to redirect_to(edit_unpublished_crossword_path(ucw))
      end

      it 're-renders form with errors when title is too short' do
        expect {
          post '/unpublished_crosswords',
               params: { unpublished_crossword: { title: 'AB', rows: 5, cols: 5 } }
        }.not_to change(UnpublishedCrossword, :count)

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include('too short')
      end

      it 're-renders form with errors when title is blank' do
        post '/unpublished_crosswords',
             params: { unpublished_crossword: { title: '', rows: 5, cols: 5 } }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include("can&#39;t be blank")
      end

      it 're-renders form with errors when dimensions are out of range' do
        post '/unpublished_crosswords',
             params: { unpublished_crossword: { title: 'Valid Title', rows: 50, cols: 5 } }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include('not included in the list')
      end
    end

    context 'when anonymous' do
      it 'redirects to account_required' do
        post '/unpublished_crosswords',
             params: { unpublished_crossword: { title: 'Test', rows: 5, cols: 5 } }

        expect(response).to have_http_status(:redirect)
        expect(response.location).to start_with("http://www.example.com#{account_required_path}")
      end
    end
  end

  # -----------------------------------------------------------------------
  # PATCH /unpublished_crosswords/:id/update_letters
  # -----------------------------------------------------------------------
  describe 'PATCH /unpublished_crosswords/:id/update_letters' do
    before { log_in_as(owner) }

    let(:ucw) { create(:unpublished_crossword, rows: 4, cols: 4, user: owner) }

    it 'preserves empty cells as empty strings, not voids' do
      # JS sends " " (space) for unfilled non-void cells
      letters = [" ", "A", " ", " "] * 4

      patch "/unpublished_crosswords/#{ucw.id}/update_letters",
        params: { letters: letters, circles: ucw.circles,
                  across_clues: ucw.across_clues, down_clues: ucw.down_clues,
                  save_counter: "1" }.to_json,
        headers: { 'Content-Type' => 'application/json', 'Accept' => 'application/json' }

      expect(response).to have_http_status(:ok)

      ucw.reload
      # Empty cells should be "" not nil (nil = void)
      expect(ucw.letters[0]).to eq ''
      expect(ucw.letters[2]).to eq ''
      # Letters should be preserved
      expect(ucw.letters[1]).to eq 'A'
      # No cells should have become voids
      expect(ucw.letters.count(&:nil?)).to eq 0
    end

    it 'stores void markers (sent as "0") as nil' do
      letters = %w[A 0 B 0 C D E F G H I J K L M N]

      patch "/unpublished_crosswords/#{ucw.id}/update_letters",
        params: { letters: letters, circles: ucw.circles,
                  across_clues: ucw.across_clues, down_clues: ucw.down_clues,
                  save_counter: "1" }.to_json,
        headers: { 'Content-Type' => 'application/json', 'Accept' => 'application/json' }

      expect(response).to have_http_status(:ok)

      ucw.reload
      expect(ucw.letters[1]).to be_nil  # void
      expect(ucw.letters[3]).to be_nil  # void
      expect(ucw.letters[0]).to eq 'A'  # letter preserved
      expect(ucw.letters[2]).to eq 'B'  # letter preserved
    end

    it 'handles a mix of letters, voids, and empty cells correctly' do
      # Simulate a realistic save: some filled, some void, most empty (16 cells for 4×4)
      letters = ["A", " ", "0", " ", "B", " ", "0", " ", "C", " ", " ", " ", " ", " ", " ", " "]

      patch "/unpublished_crosswords/#{ucw.id}/update_letters",
        params: { letters: letters, circles: ucw.circles,
                  across_clues: ucw.across_clues, down_clues: ucw.down_clues,
                  save_counter: "1" }.to_json,
        headers: { 'Content-Type' => 'application/json', 'Accept' => 'application/json' }

      expect(response).to have_http_status(:ok)

      ucw.reload
      expect(ucw.letters[0]).to eq 'A'   # letter
      expect(ucw.letters[1]).to eq ''    # empty (was " ")
      expect(ucw.letters[2]).to be_nil   # void (was "0")
      expect(ucw.letters[3]).to eq ''    # empty (was " ")
      expect(ucw.letters[4]).to eq 'B'   # letter
      expect(ucw.letters[8]).to eq 'C'   # letter
    end

    it 'returns the save_counter in the response' do
      letters = [" "] * 16

      patch "/unpublished_crosswords/#{ucw.id}/update_letters",
        params: { letters: letters, circles: ucw.circles,
                  across_clues: ucw.across_clues, down_clues: ucw.down_clues,
                  save_counter: "abc123" }.to_json,
        headers: { 'Content-Type' => 'application/json', 'Accept' => 'application/json' }

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body['save_counter']).to eq 'abc123'
    end
  end

  # -----------------------------------------------------------------------
  # PATCH /unpublished_crosswords/:id/publish
  # -----------------------------------------------------------------------
  describe 'PATCH /unpublished_crosswords/:id/publish' do
    context 'when the owner publishes a complete puzzle' do
      before { log_in_as(owner) }

      it 'creates a Crossword, destroys the UCW, and redirects' do
        ucw = create_publishable_ucw(user: owner)

        expect {
          patch "/unpublished_crosswords/#{ucw.id}/publish"
        }.to change(Crossword, :count).by(1)
         .and change(UnpublishedCrossword, :count).by(-1)

        crossword = Crossword.order(:created_at).last
        expect(response).to redirect_to(crossword_path(crossword))
      end

      it 'copies title, description, dimensions, and user' do
        ucw = create_publishable_ucw(user: owner)
        patch "/unpublished_crosswords/#{ucw.id}/publish"

        cw = Crossword.order(:created_at).last
        expect(cw.title).to eq ucw.title
        expect(cw.rows).to eq 4
        expect(cw.cols).to eq 4
        expect(cw.user).to eq owner
      end

      it 'preserves void positions in the published letters' do
        ucw = create_publishable_ucw(user: owner)
        patch "/unpublished_crosswords/#{ucw.id}/publish"

        cw = Crossword.order(:created_at).last
        expect(cw.letters[3]).to eq '_'   # void at index 3
        expect(cw.letters[12]).to eq '_'  # void at index 12
        expect(cw.letters[0]).to eq 'A'   # non-void letter preserved
      end

      it 'transfers clue content to the published crossword' do
        ucw = create_publishable_ucw(user: owner)
        patch "/unpublished_crosswords/#{ucw.id}/publish"

        cw = Crossword.order(:created_at).last
        across_contents = cw.cells.select(&:is_across_start).filter_map { |c| c.across_clue&.content }
        expect(across_contents).to include('First across')
      end
    end

    context 'when the puzzle has blank cells' do
      before { log_in_as(owner) }

      it 'refuses to publish and redirects back with an error' do
        ucw = create(:unpublished_crossword, rows: 4, cols: 4, user: owner)

        expect {
          patch "/unpublished_crosswords/#{ucw.id}/publish"
        }.not_to change(Crossword, :count)

        expect(response).to redirect_to(edit_unpublished_crossword_path(ucw))
        expect(flash[:error]).to match(/blank/)
      end
    end

    context 'when a non-owner tries to publish' do
      before { log_in_as(other) }

      it 'redirects with a warning' do
        ucw = create_publishable_ucw(user: owner)

        expect {
          patch "/unpublished_crosswords/#{ucw.id}/publish"
        }.not_to change(Crossword, :count)

        expect(response).to redirect_to(root_path)
      end
    end

    context 'when anonymous' do
      it 'redirects to account_required' do
        ucw = create_publishable_ucw(user: owner)

        expect {
          patch "/unpublished_crosswords/#{ucw.id}/publish"
        }.not_to change(Crossword, :count)

        expect(response).to have_http_status(:redirect)
      end
    end
  end
end
