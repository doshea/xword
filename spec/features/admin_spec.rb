feature 'Admin', js: true do
  let!(:admin) { create(:admin, password: 'adminpass1', password_confirmation: 'adminpass1') }

  before :each do
    page.driver.browser.cookies.clear

    visit login_path
    expect(page).to have_css('form#login')
    within('form#login') do
      fill_in :username, with: admin.username
      fill_in :password, with: admin.password
      click_button 'Log in'
    end
    expect(page).to have_text("Welcome back")
  end

  context 'nav dropdown' do
    scenario 'clicking Admin button opens dropdown menu' do
      # The admin dropdown should be hidden initially
      expect(page).not_to have_css('.xw-nav__dropdown.is-open')

      # Click the Admin button
      find('button', text: 'Admin').click

      # The dropdown should now be open with admin links
      expect(page).to have_css('.xw-nav__dropdown.is-open')
      within('.xw-nav__dropdown.is-open') do
        expect(page).to have_link('Users')
        expect(page).to have_link('Crosswords')
        expect(page).to have_link('Clues')
      end
    end

    scenario 'clicking an admin link navigates to that page' do
      find('button', text: 'Admin').click
      within('.xw-nav__dropdown.is-open') do
        click_link 'Users'
      end
      expect(page).to have_current_path(admin_users_path)
    end

    scenario 'clicking outside closes the dropdown' do
      find('button', text: 'Admin').click
      expect(page).to have_css('.xw-nav__dropdown.is-open')

      # Click outside the dropdown
      find('h1').click
      expect(page).not_to have_css('.xw-nav__dropdown.is-open')
    end
  end

  context 'pagination' do
    before :each do
      # Lower per_page so we don't need to create many records.
      # per_page is a class attribute visible across threads.
      @original_per_page = User.per_page
      User.per_page = 2

      # Create additional users (admin + these = 3 total, so 2 pages with per_page=2)
      create_list(:user, 2)
    end

    after :each do
      User.per_page = @original_per_page
    end

    scenario 'pagination links navigate between pages' do
      visit admin_users_path
      expect(page).to have_css('.xw-pagination')

      # Should show page 1 content and have a link to page 2
      expect(page).to have_link('2')
      expect(page).to have_link('Next')

      # Click page 2
      within('.xw-pagination') do
        click_link '2'
      end

      # URL should include page=2
      expect(page).to have_current_path(/page=2/)

      # Page 2 should show remaining users and have a link back to page 1
      within('.xw-pagination') do
        expect(page).to have_link('1')
        expect(page).to have_link('Previous')
      end
    end
  end
end
