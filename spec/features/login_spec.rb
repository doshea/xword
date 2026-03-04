feature 'Login' do

  before :each do
    @user = create(:user)
  end

  context 'Anonymous user' do
    context 'visiting home page' do
      before :each do
        visit root_path
      end
      scenario 'arrive on home page successfully' do
        expect(page).to have_current_path(root_path)
      end
    end

    context 'visiting login page' do
      before :each do
        visit login_path
      end
      scenario 'can log in' do
        within('form#login') do
          fill_in :username, with: @user.username
          fill_in :password, with: @user.password
          click_button 'Log in'
        end

        expect(page).to have_current_path(root_path)
        expect(page).not_to have_selector('#login-container')
        expect(page).to have_text("Welcome back, #{@user.username}")
      end
      scenario 'can see Forgot Password link and navigate using it' do
        forgot_password_text = 'Forgot your password?'
        expect(page).to have_link(forgot_password_text)
        click_link(forgot_password_text)
        expect(page).to have_current_path(forgot_password_users_path)
      end
    end

    context 'using nav login link', js: true do
      before :each do
        page.driver.browser.cookies.clear
        visit user_path(@user)
      end
      scenario 'Login link is in the nav' do
        expect(page).to have_link('Login')
      end
      scenario 'clicking Login navigates to login page and logs in with good credentials' do
        click_link 'Login'
        within('form#login') do
          fill_in :username, with: @user.username
          fill_in :password, with: @user.password
          click_button 'Log in'
        end
        expect(page).to have_text('Welcome back')
        expect(page).not_to have_link('Login')
      end
      scenario 'bad credentials show error message' do
        click_link 'Login'
        within('form#login') do
          fill_in :username, with: @user.username
          fill_in :password, with: 'BADPASSWORD'
          click_button 'Log in'
        end
        expect(page).to have_text("Username/password combination did not match our records")
      end
    end
  end
end
