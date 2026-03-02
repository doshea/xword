feature 'Edit crossword', js: true do
  let!(:user) { create(:user, password: 'testpass123', password_confirmation: 'testpass123') }
  let!(:ucw) { create(:unpublished_crossword, user: user, title: 'Test Puzzle') }

  before :each do
    page.driver.browser.cookies.clear

    visit login_path
    expect(page).to have_css('form#login')
    within('form#login') do
      fill_in :username, with: user.username
      fill_in :password, with: 'testpass123'
      click_button 'Log in'
    end
    expect(page).to have_text('Welcome back')

    visit edit_unpublished_crossword_path(ucw)
    expect(page).to have_css('table#crossword')
  end

  # Helper: wait for the 0.4s CSS slide-up transition to settle so Cuprite
  # clicks hit the correct screen coordinates.
  def wait_for_panel_transition
    sleep 0.5
  end

  # -----------------------------------------------------------------------
  # Settings modal
  # -----------------------------------------------------------------------
  scenario 'clicking the gear icon opens the settings modal' do
    find('#settings-button').click
    expect(page).to have_css('dialog#edit-settings[open]')
    expect(page).to have_text('Edit Settings')
  end

  scenario 'closing the settings modal via the close button' do
    find('#settings-button').click
    expect(page).to have_css('dialog#edit-settings[open]')
    find('.xw-modal__close').click
    expect(page).not_to have_css('dialog#edit-settings[open]')
  end

  # -----------------------------------------------------------------------
  # Ideas / Notepad panel
  # -----------------------------------------------------------------------
  scenario 'clicking the lightbulb icon toggles the notepad panel' do
    find('#ideas-button').click
    expect(page).to have_css('#idea-container.open')

    # Wait for the slide-up transition before clicking the same button again;
    # the button moves during the transition and Cuprite misses it otherwise.
    wait_for_panel_transition
    find('#ideas-button').click
    expect(page).not_to have_css('#idea-container.open')
  end

  scenario 'adding a word via the notepad' do
    find('#ideas-button').click
    expect(page).to have_css('#idea-container.open')
    wait_for_panel_transition

    fill_in 'word', with: 'HELLO'
    find('#ideas-input').send_keys(:return)

    expect(page).to have_css('#potential-words-list li', text: 'HELLO')
  end

  scenario 'adding a duplicate word shows an error' do
    ucw.update!(potential_words: ['HELLO'])

    visit edit_unpublished_crossword_path(ucw)
    expect(page).to have_css('table#crossword')

    find('#ideas-button').click
    expect(page).to have_css('#idea-container.open')
    wait_for_panel_transition

    fill_in 'word', with: 'HELLO'
    find('#ideas-input').send_keys(:return)

    # Error text is inside #ideas which has CSS text-transform: uppercase;
    # use visible: :all since the error element may be in an overflow area
    expect(page).to have_css('#ideas-error', text: /word already added to list/i, visible: :all)
  end

  # -----------------------------------------------------------------------
  # Pattern search panel
  # -----------------------------------------------------------------------
  scenario 'clicking the magnifying glass toggles the pattern search panel' do
    find('#pattern-search-button').click
    expect(page).to have_css('#pattern-container.open')

    # Wait for the slide-up transition before clicking the same button again
    wait_for_panel_transition
    find('#pattern-search-button').click
    expect(page).not_to have_css('#pattern-container.open')
  end

  scenario 'pattern search panel contains form and results area' do
    find('#pattern-search-button').click
    expect(page).to have_css('#pattern-container.open')
    expect(page).to have_css('#pattern-search form')
    expect(page).to have_css('#pattern-search input[name="pattern"]')
    expect(page).to have_css('#word-match-results')
  end

  # -----------------------------------------------------------------------
  # Remove potential word
  # -----------------------------------------------------------------------
  scenario 'removing a word from the notepad' do
    ucw.update!(potential_words: ['HELLO'])

    visit edit_unpublished_crossword_path(ucw)
    expect(page).to have_css('table#crossword')

    find('#ideas-button').click
    expect(page).to have_css('#potential-words-list li', text: 'HELLO')
    wait_for_panel_transition

    find('a[aria-label="Remove HELLO from word list"]').click
    expect(page).not_to have_css('#potential-words-list li', text: 'HELLO')
  end
end
