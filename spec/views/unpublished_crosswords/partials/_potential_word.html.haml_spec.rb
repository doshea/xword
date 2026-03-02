require 'spec_helper'

describe 'unpublished_crosswords/partials/_potential_word' do
  let(:user) { create(:user) }
  # MIN_DIMENSION is 4; use 5x5 to be safely above it
  let(:ucw)  { UnpublishedCrossword.create!(title: 'Test', rows: 5, cols: 5, user: user) }

  before { assign(:unpublished_crossword, ucw) }

  context 'for a typical word' do
    let(:word) { 'EXAMPLE' }

    before { render partial: 'unpublished_crosswords/partials/potential_word', locals: { word: word } }

    it 'displays the word' do
      expect(rendered).to have_text(word)
    end

    it 'shows the word length' do
      expect(rendered).to have_text("(#{word.length})")
    end

    it 'gives the delete link an aria-label that names the word being removed' do
      expect(rendered).to have_selector(
        "a[aria-label='Remove #{word} from word list']",
        visible: :all
      )
    end

    it 'does not use inline style attributes' do
      expect(rendered).not_to have_selector('[style]', visible: :all)
    end
  end

  context 'for a short word' do
    let(:word) { 'GO' }

    before { render partial: 'unpublished_crosswords/partials/potential_word', locals: { word: word } }

    it 'gives the delete link an aria-label referencing that specific word' do
      expect(rendered).to have_selector(
        "a[aria-label='Remove #{word} from word list']",
        visible: :all
      )
    end
  end
end
