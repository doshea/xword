feature 'Accessibility' do
  # -----------------------------------------------------------------------
  # Shared examples: structural landmarks every page must have
  # -----------------------------------------------------------------------
  shared_examples 'accessible layout' do
    it 'has a skip-to-content link that points to the main landmark' do
      expect(page).to have_selector('a.skip-to-content[href="#body"]',
                                    text: 'Skip to main content',
                                    visible: :all)
    end

    it 'wraps the page body in a <main> landmark' do
      expect(page).to have_selector('main#body')
    end

    it 'wraps the nav bar in a <header> landmark' do
      expect(page).to have_selector('header#nav')
    end

    it 'has a footer site-information nav labelled for screen readers' do
      expect(page).to have_selector('footer#footer nav[aria-label="Site information"]')
    end
  end

  # -----------------------------------------------------------------------
  # Anonymous user
  # -----------------------------------------------------------------------
  context 'anonymous user' do
    context 'on the welcome page' do
      before { visit root_path }

      it 'wraps the page body in a <main> landmark' do
        expect(page).to have_selector('main#body')
      end

      it 'has a skip-to-content link that points to the main landmark' do
        expect(page).to have_selector('a.skip-to-content[href="#body"]',
                                      text: 'Skip to main content',
                                      visible: :all)
      end
    end

    context 'on the login page' do
      before { visit login_path }

      include_examples 'accessible layout'
    end

    context 'on a crossword page' do
      let!(:crossword) { create(:predefined_five_by_five) }

      before { visit crossword_path(crossword) }

      include_examples 'accessible layout'

      it 'wraps the puzzle header in a <header> landmark' do
        expect(page).to have_selector('header#credit-area')
      end

      it 'renders the puzzle title as the page h1' do
        expect(page).to have_selector('header#credit-area h1', text: crossword.title)
      end

      it 'wraps the grid in a labelled <section>' do
        expect(page).to have_selector('section#solve-area[aria-label="Puzzle grid"]')
      end

      it 'wraps the description and comments in a labelled <section>' do
        expect(page).to have_selector('section#meta-area[aria-label="Puzzle information"]')
      end

      it 'labels the comments section via aria-labelledby' do
        expect(page).to have_selector('section#comments[aria-labelledby="comments-heading"]')
      end

      it 'renders the Comments heading as h2 with the matching id' do
        expect(page).to have_selector('h2#comments-heading', text: 'Comments')
      end

      it 'gives the crossword grid table an aria-label with the puzzle title' do
        expect(page).to have_selector(
          "table#crossword[aria-label='#{crossword.title} crossword grid']"
        )
      end
    end
  end

  # -----------------------------------------------------------------------
  # Logged-in user
  # -----------------------------------------------------------------------
  context 'logged-in user' do
    let!(:user) { create(:user) }

    before do
      visit login_path
      within('form#login') do
        fill_in :username, with: user.username
        fill_in :password, with: user.password
        click_button 'Log in'
      end
    end

    context 'on the home page' do
      before { visit root_path }

      include_examples 'accessible layout'

      it 'uses a personalised h1 heading' do
        expect(page).to have_selector('h1', text: 'Welcome back')
      end

      it 'uses span.tab-label for tab labels, not heading elements inside buttons' do
        expect(page).to have_selector('button > .tab-label')
        expect(page).not_to have_selector('.tabs button h5')
      end
    end

    context 'on a crossword page' do
      let!(:crossword) { create(:predefined_five_by_five) }

      before { visit crossword_path(crossword) }

      it 'gives the quicksave button an aria-label' do
        expect(page).to have_selector('#solve-save[aria-label="Save"]', visible: :all)
      end

      it 'gives the favorite button an aria-label' do
        expect(page).to have_selector('#favorite[aria-label="Add to favorites"]', visible: :all)
      end

      it 'gives the unfavorite button an aria-label' do
        expect(page).to have_selector('#unfavorite[aria-label="Remove from favorites"]', visible: :all)
      end

      it 'gives the puzzle controls button an aria-label' do
        expect(page).to have_selector('#controls-button[aria-label="Puzzle controls"]')
      end

      it 'gives the delete-solution link an aria-label' do
        expect(page).to have_selector('a[aria-label="Delete solution"]')
      end

      it 'gives the create-team link an aria-label' do
        expect(page).to have_selector('a[aria-label="Solve with a team"]')
      end
    end
  end
end
