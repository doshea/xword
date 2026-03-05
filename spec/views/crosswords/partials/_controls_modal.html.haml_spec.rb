require 'spec_helper'

describe 'crosswords/partials/_controls_modal' do
  before do
    assign(:current_user, create(:user))
    assign(:team, nil)
    render partial: 'crosswords/partials/controls_modal'
  end

  it 'renders as a native dialog element' do
    expect(rendered).to have_selector('dialog#controls-modal.xw-modal', visible: :all)
  end

  it 'renders the heading "How to Solve"' do
    expect(rendered).to have_selector('h2', text: 'How to Solve', visible: :all)
    expect(rendered).not_to have_selector('h1', visible: :all)
  end

  it 'renders kbd elements for keyboard shortcuts' do
    expect(rendered).to have_selector('kbd', text: 'Tab', visible: :all)
    expect(rendered).to have_selector('kbd', text: 'Enter', visible: :all)
    expect(rendered).to have_selector('kbd', text: /Space/, visible: :all)
    expect(rendered).to have_selector('kbd', text: 'Esc', visible: :all)
    expect(rendered).to have_selector('kbd', text: 'Backspace', visible: :all)
  end

  it 'renders a close button with aria-label' do
    expect(rendered).to have_selector('button.xw-modal__close[aria-label="Close"]', visible: :all)
  end

  it 'renders all standard sections' do
    %w[Navigation Comments Saving].each do |section|
      expect(rendered).to have_selector('h3', text: section, visible: :all)
    end
    expect(rendered).to have_selector('h3', text: 'Entering Letters', visible: :all)
    expect(rendered).to have_selector('h3', text: 'Checking Your Work', visible: :all)
    expect(rendered).to have_selector('h3', text: 'Getting Help', visible: :all)
  end

  it 'does not render team section when @team is nil' do
    expect(rendered).not_to have_selector('h3', text: 'Team Solving', visible: :all)
  end

  context 'when team solve is active' do
    before do
      assign(:team, true)
      render partial: 'crosswords/partials/controls_modal'
    end

    it 'renders the Team Solving section' do
      expect(rendered).to have_selector('h3', text: 'Team Solving', visible: :all)
    end
  end

  it 'does not use inline style attributes' do
    expect(rendered).not_to have_selector('[style]', visible: :all)
  end
end
