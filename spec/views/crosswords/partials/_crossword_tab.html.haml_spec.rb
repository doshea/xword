require 'spec_helper'

describe 'crosswords/partials/_crossword_tab' do
  context 'with a published Crossword' do
    let(:crossword) { create(:predefined_five_by_five) }

    before do
      render partial: 'crosswords/partials/crossword_tab',
             locals: { cw: crossword }
    end

    it 'renders without error' do
      expect(rendered).to have_selector('.result-crossword')
    end

    it 'displays the crossword title' do
      expect(rendered).to have_text(crossword.title)
    end

    it 'links directly to the puzzle' do
      expect(rendered).to have_link(href: crossword_path(crossword))
    end

    it 'does not use legacy shadow or thin-border classes on images' do
      expect(rendered).not_to have_selector('img.shadow', visible: :all)
      expect(rendered).not_to have_selector('img.thin-border', visible: :all)
    end
  end

  context 'with an UnpublishedCrossword' do
    let(:user) { create(:user) }
    let(:unpublished) do
      UnpublishedCrossword.create!(
        title: 'Draft Puzzle',
        rows: 5,
        cols: 5,
        user_id: user.id
      )
    end

    before do
      render partial: 'crosswords/partials/crossword_tab',
             locals: { cw: unpublished, unpublished: true }
    end

    it 'renders without error' do
      expect(rendered).to have_selector('.result-crossword')
    end

    it 'displays the unpublished crossword title' do
      expect(rendered).to have_text('Draft Puzzle')
    end

    it 'links to the edit page' do
      expect(rendered).to have_link(href: edit_unpublished_crossword_path(unpublished))
    end
  end
end
