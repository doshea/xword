feature 'Home page tabs', js: true do
  let!(:user) { create(:user, password: 'testpass123', password_confirmation: 'testpass123') }
  let!(:other_user) { create(:user) }
  let!(:crossword) { create(:predefined_five_by_five, user: other_user) }
  let!(:solution) { create(:solution, user: user, crossword: crossword, is_complete: false) }

  before :each do
    # Clear any stale browser state from previous examples
    page.driver.browser.cookies.clear

    visit login_path
    expect(page).to have_css('form#login')
    within('form#login') do
      fill_in :username, with: user.username
      fill_in :password, with: user.password
      click_button 'Log in'
    end
    expect(page).to have_text("Welcome back")
  end

  scenario 'In Progress tab switches to show in-progress puzzles' do
    # The New Puzzles tab should be active by default
    expect(page).to have_css('.xw-tab--active', text: 'Puzzles')
    expect(page).to have_css('#panel1.xw-tab-panel--active')

    # Click the In Progress tab
    find('.xw-tab', text: 'In Progress').click

    # The In Progress panel should now be visible
    expect(page).to have_css('#panel2.xw-tab-panel--active')
    expect(page).not_to have_css('#panel1.xw-tab-panel--active')
  end

  scenario 'Solved Puzzles tab switches panels' do
    find('.xw-tab', text: 'Solved Puzzles').click
    expect(page).to have_css('#panel3.xw-tab-panel--active')
    expect(page).not_to have_css('#panel1.xw-tab-panel--active')
  end

  scenario 'clicking back to first tab restores it' do
    find('.xw-tab', text: 'In Progress').click
    expect(page).to have_css('#panel2.xw-tab-panel--active')

    find('.xw-tab', text: /New Puzzles/).click
    expect(page).to have_css('#panel1.xw-tab-panel--active')
    expect(page).not_to have_css('#panel2.xw-tab-panel--active')
  end
end
