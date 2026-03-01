require 'spec_helper'

describe 'crosswords/show' do
  let(:owner)     { create(:user) }
  let(:crossword) { create(:predefined_five_by_five, user: owner) }

  def base_assigns(current_user: nil, solution: nil, is_favorited: false)
    assign(:crossword,    crossword)
    assign(:current_user, current_user)
    assign(:solution,     solution)
    assign(:is_favorited, is_favorited)
    assign(:comments,     [])
    assign(:cells,        crossword.cells.asc_indices)
    assign(:team,         nil)
  end

  # -----------------------------------------------------------------------
  # Landmarks and heading hierarchy
  # -----------------------------------------------------------------------
  context 'landmark and heading structure (anonymous user)' do
    before { base_assigns; render }

    it 'wraps the credit area in a <header> element' do
      expect(rendered).to have_selector('header#credit-area', visible: :all)
    end

    it 'renders the puzzle title as h1 inside the header' do
      expect(rendered).to have_selector('header#credit-area h1', text: crossword.title, visible: :all)
    end

    it 'does not render the title as h3 or any other non-h1 heading' do
      expect(rendered).not_to have_selector('header#credit-area h3', visible: :all)
    end

    it 'wraps the solve area in a labelled <section>' do
      expect(rendered).to have_selector('section#solve-area[aria-label="Puzzle grid"]', visible: :all)
    end

    it 'wraps the meta area in a labelled <section>' do
      expect(rendered).to have_selector('section#meta-area[aria-label="Puzzle information"]', visible: :all)
    end

    it 'marks the comments section with aria-labelledby' do
      expect(rendered).to have_selector('section#comments[aria-labelledby="comments-heading"]', visible: :all)
    end

    it 'renders the Comments heading as h2 with the matching id' do
      expect(rendered).to have_selector('h2#comments-heading', text: 'Comments', visible: :all)
    end
  end

  # -----------------------------------------------------------------------
  # Crossword grid table
  # -----------------------------------------------------------------------
  context 'puzzle grid table (anonymous user)' do
    before { base_assigns; render }

    it 'gives the grid table an aria-label containing the puzzle title' do
      expect(rendered).to have_selector(
        "table#crossword[aria-label='#{crossword.title} crossword grid']",
        visible: :all
      )
    end
  end

  # -----------------------------------------------------------------------
  # Icon-only controls — only rendered for logged-in users
  # -----------------------------------------------------------------------
  context 'icon-only controls (logged-in user)' do
    let(:viewer)   { create(:user) }
    let(:solution) { create(:solution, user: viewer, crossword: crossword) }

    before { base_assigns(current_user: viewer, solution: solution); render }

    it 'gives the quicksave button an aria-label' do
      expect(rendered).to have_selector('#solve-save[aria-label="Quicksave"]', visible: :all)
    end

    it 'gives the favorite button an aria-label' do
      expect(rendered).to have_selector('#favorite[aria-label="Add to favorites"]', visible: :all)
    end

    it 'gives the unfavorite button an aria-label' do
      expect(rendered).to have_selector('#unfavorite[aria-label="Remove from favorites"]', visible: :all)
    end

    it 'gives the puzzle-controls button an aria-label' do
      expect(rendered).to have_selector('#controls-button[aria-label="Puzzle controls"]', visible: :all)
    end

    it 'gives the delete-solution link an aria-label' do
      expect(rendered).to have_selector('a[aria-label="Delete solution"]', visible: :all)
    end

    it 'gives the create-team link an aria-label' do
      expect(rendered).to have_selector('a[aria-label="Solve with a team"]', visible: :all)
    end

    it 'does not leave any link in #puzzle-controls without an accessible label' do
      expect(rendered).not_to have_selector(
        '#puzzle-controls a:not([aria-label]):not([title])',
        visible: :all
      )
    end
  end
end
