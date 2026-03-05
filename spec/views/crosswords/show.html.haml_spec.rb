require 'spec_helper'

describe 'crosswords/show' do
  let_it_be(:owner)     { create(:user) }
  let_it_be(:crossword) { create(:predefined_five_by_five, user: owner) }

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
      expect(rendered).to have_selector('#solve-save[aria-label="Save"]', visible: :all)
    end

    it 'gives the favorite button an aria-label' do
      expect(rendered).to have_selector('#favorite[aria-label="Add to favorites"]', visible: :all)
    end

    it 'gives the unfavorite button an aria-label' do
      expect(rendered).to have_selector('#unfavorite[aria-label="Remove from favorites"]', visible: :all)
    end

    it 'gives the puzzle-controls button an aria-label' do
      expect(rendered).to have_selector('#controls-button[aria-label="How to solve"]', visible: :all)
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

    it 'does not use inline style on the unfavorite star icon' do
      expect(rendered).not_to have_selector('#unfavorite svg[style]', visible: :all)
    end
  end

  # -----------------------------------------------------------------------
  # Inline styles and legacy utility classes
  # -----------------------------------------------------------------------
  context 'inline styles and legacy classes (anonymous user)' do
    before { base_assigns; render }

    it 'does not use legacy shadow utility classes on images' do
      expect(rendered).not_to have_selector('img.small-shadow', visible: :all)
      expect(rendered).not_to have_selector('img.shadow', visible: :all)
    end

    it 'does not use legacy .thin-border class on images' do
      expect(rendered).not_to have_selector('img.thin-border', visible: :all)
    end
  end

  # -----------------------------------------------------------------------
  # Creator credit byline
  # -----------------------------------------------------------------------
  context 'creator credit byline' do
    before { base_assigns; render }

    it 'renders the creator credit inside the h1' do
      expect(rendered).to have_selector('h1 #creator-credit', visible: :all)
    end

    it 'includes the creator display name in the byline' do
      expect(rendered).to have_selector('#creator-credit', text: /by #{owner.display_name}/, visible: :all)
    end
  end

  # -----------------------------------------------------------------------
  # Comment rendering (with comments present, logged-in user)
  # -----------------------------------------------------------------------
  context 'comment actions (logged-in user with comments)' do
    let(:viewer)   { create(:user) }
    let(:solution) { create(:solution, user: viewer, crossword: crossword) }
    let(:comment)  { create(:comment, user: owner, crossword: crossword) }

    before do
      base_assigns(current_user: viewer, solution: solution)
      assign(:comments, [comment])
      render
    end

    it 'renders the reply textarea with xw-textarea class' do
      expect(rendered).to have_selector('textarea.reply-content.xw-textarea', visible: :all)
    end

    it 'does not use inline style on the reply button' do
      expect(rendered).not_to have_selector('.reply-button.reply[style]', visible: :all)
    end

    it 'does not use inline style on the cancel button' do
      expect(rendered).not_to have_selector('.cancel-button[style]', visible: :all)
    end

    it 'does not use inline style on the reply form' do
      expect(rendered).not_to have_selector('form.reply-form[style]', visible: :all)
    end
  end
end
