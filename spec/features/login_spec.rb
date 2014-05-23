feature 'Login' do

  before :each do
    create(:min_user)
  end

  scenario 'Anonymous users are redirected from root to welcome page' do
    visit root_path
    current_path.should eq welcome_path
  end

  scenario 'Anonymous users can log in' do
    visit root_path
    page.should have_selector('#login-container')

    within('#login-container') do
      fill_in :username, with: 'min_user'
      fill_in :password, with: 'abcde'
      click_button 'Log in'
    end

    visit root_path
    current_path.should eq root_path
    page.should_not have_selector('#login-container')
    expect(page).to have_text("Welcome back")

  end

  scenario 'Signing in from welcome page with bad credentials redirects to welcome page' do
    visit root_path

    within('#login-container') do
      fill_in :username, with: 'min_user'
      fill_in :password, with: 'wrong'
      click_button 'Log in'
    end

    visit root_path
    current_path.should eq welcome_path
    page.should have_selector('#login-container')
    expect(page).to_not have_text("Welcome back")
  end

end