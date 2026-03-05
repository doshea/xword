require 'spec_helper'

describe 'crosswords/partials/_controls_modal' do
  before do
    assign(:current_user, create(:user))
    assign(:team, nil)
    render partial: 'crosswords/partials/controls_modal'
  end

  it 'renders as a native dialog with a close button' do
    expect(rendered).to have_selector('dialog#controls-modal', visible: :all)
    expect(rendered).to have_selector('button[aria-label="Close"]', visible: :all)
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
end
