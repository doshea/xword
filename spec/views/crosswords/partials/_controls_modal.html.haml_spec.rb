require 'spec_helper'

describe 'crosswords/partials/_controls_modal' do
  before do
    render partial: 'crosswords/partials/controls_modal'
  end

  it 'renders as a native dialog element' do
    expect(rendered).to have_selector('dialog#controls-modal.xw-modal', visible: :all)
  end

  it 'does not use the deprecated <u> tag' do
    expect(rendered).not_to have_selector('u', visible: :all)
  end

  it 'renders the heading as h2, not h1' do
    expect(rendered).to have_selector('h2', text: 'Controls', visible: :all)
    expect(rendered).not_to have_selector('h1', visible: :all)
  end

  it 'does not use inline style attributes' do
    expect(rendered).not_to have_selector('[style]', visible: :all)
  end

  it 'renders kbd elements for keyboard shortcuts' do
    expect(rendered).to have_selector('kbd', text: 'Tab', visible: :all)
    expect(rendered).to have_selector('kbd', text: 'Enter', visible: :all)
    expect(rendered).to have_selector('kbd', text: /Space/, visible: :all)
  end

  it 'renders a close button with aria-label' do
    expect(rendered).to have_selector('button.xw-modal__close[aria-label="Close"]', visible: :all)
  end
end
