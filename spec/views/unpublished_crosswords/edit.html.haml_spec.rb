require 'spec_helper'

describe 'unpublished_crosswords/edit' do
  let(:user) { create(:user) }
  # MIN_DIMENSION is 4; use 5x5 to be safely above it
  let(:ucw)  { UnpublishedCrossword.create!(title: 'My Puzzle', rows: 5, cols: 5, user: user) }

  before do
    assign(:unpublished_crossword, ucw)
    assign(:current_user, user)
    assign(:clue_numbers, ucw.letters_to_clue_numbers)
    render
  end

  # -----------------------------------------------------------------------
  # Landmark structure
  # -----------------------------------------------------------------------
  it 'wraps the title/save area in a <header> element' do
    expect(rendered).to have_selector('header#credit-area', visible: :all)
  end

  it 'wraps the grid editor in a labelled <section>' do
    expect(rendered).to have_selector('section#solve-area[aria-label="Edit puzzle grid"]', visible: :all)
  end

  it 'wraps the description area in a <section>' do
    expect(rendered).to have_selector('section#meta-area', visible: :all)
  end

  it 'wraps the advanced controls in a section labelled by its heading' do
    expect(rendered).to have_selector('section#advanced[aria-labelledby="advanced-heading"]', visible: :all)
  end

  # -----------------------------------------------------------------------
  # Heading hierarchy
  # -----------------------------------------------------------------------
  it 'renders "Advanced Controls" as h2, not h5' do
    expect(rendered).to have_selector('h2#advanced-heading', text: 'Advanced Controls', visible: :all)
    expect(rendered).not_to have_selector('h5', text: 'Advanced Controls', visible: :all)
  end

  # -----------------------------------------------------------------------
  # Quicksave button
  # -----------------------------------------------------------------------
  it 'gives the quicksave button an aria-label' do
    expect(rendered).to have_selector('#edit-save[aria-label="Quicksave"]', visible: :all)
  end
end
