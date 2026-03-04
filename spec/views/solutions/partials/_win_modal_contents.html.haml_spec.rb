require 'spec_helper'

describe 'solutions/partials/_win_modal_contents' do
  let(:user)      { create(:user) }
  let(:crossword) { create(:crossword, :smaller, user: user) }
  let(:solution)  { create(:solution, user: user, crossword: crossword) }

  context 'logged-in user who solved the puzzle (no prior comment)' do
    before do
      assign(:correctness, true)
      assign(:current_user, user)
      assign(:crossword, crossword)
      assign(:solution, solution)
      assign(:has_commented, false)
      render partial: 'solutions/partials/win_modal_contents'
    end

    it 'renders the SOLVED heading as h2' do
      expect(rendered).to have_selector('h2', text: /SOLVED/, visible: :all)
    end

    it 'does not use inline style attributes' do
      expect(rendered).not_to have_selector('[style]', visible: :all)
    end

    it 'renders the clock display with a CSS class instead of inline bg' do
      expect(rendered).to have_selector('.win-clock', visible: :all)
      expect(rendered).not_to have_selector('.clock[style]', visible: :all)
    end

    it 'renders the comment textarea with xw-textarea class' do
      expect(rendered).to have_selector('textarea.xw-textarea', visible: :all)
    end

    it 'does not use the legacy .lead class' do
      expect(rendered).not_to have_selector('.lead', visible: :all)
    end
  end

  context 'logged-in user who already commented' do
    before do
      assign(:correctness, true)
      assign(:current_user, user)
      assign(:crossword, crossword)
      assign(:solution, solution)
      assign(:has_commented, true)
      render partial: 'solutions/partials/win_modal_contents'
    end

    it 'does not render the comment form' do
      expect(rendered).not_to have_selector('textarea', visible: :all)
    end
  end

  context 'anonymous user who solved the puzzle' do
    before do
      assign(:correctness, true)
      assign(:current_user, nil)
      assign(:crossword, crossword)
      assign(:solution, nil)
      render partial: 'solutions/partials/win_modal_contents'
    end

    it 'renders the SOLVED heading' do
      expect(rendered).to have_selector('h2', text: /SOLVED/, visible: :all)
    end

    it 'does not render the clock display' do
      expect(rendered).not_to have_selector('.win-clock', visible: :all)
    end
  end
end
