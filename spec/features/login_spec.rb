feature 'Login' do

  before :each do
    @user = create(:user)
  end

  context 'Anonymous user' do
    context 'visiting home page' do
      before :each do
        visit root_path
      end
      scenario 'are redirected to welcome page' do
        current_path.should eq welcome_path
      end

      scenario 'can log in' do
        page.should have_selector('#login-container')

        within('#login-container') do
          fill_in :username, with: @user.username
          fill_in :password, with: @user.password
          click_button 'Log in'
        end

        current_path.should eq root_path
        page.should_not have_selector('#login-container')
        expect(page).to have_text("Welcome back, #{@user.username}")

      end

      context 'with bad login' do
        before :each do
          within('#login-container') do
            fill_in :username, with: @user.username
            fill_in :password, with: 'BADPASSWORD'
            click_button 'Log in'
          end
        end

        scenario 'leads to login page' do
          current_path.should eq login_path
        end

        scenario 'receives warning' do
          page.should have_text("Username/password combination did not match our records")
        end

        scenario 'cannot reach home page' do
          visit root_path
          current_path.should eq welcome_path
          page.should have_selector('#login-container')
          expect(page).to_not have_text("Welcome back")
        end

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

        current_path.should eq root_path
        page.should_not have_selector('#login-container')
        expect(page).to have_text("Welcome back, #{@user.username}")
      end
      scenario 'can see Forgot Password link and navigate using it' do
        forgot_password_text = 'Forgot your password?'
        page.find_link(forgot_password_text).visible?.should be_true
        click_link(forgot_password_text)
        current_path.should eq forgot_password_users_path
      end
    end

    context 'using dropdown login' do
      scenario 'it is on the page'
      scenario 'it is not initially visible'
      scenario 'it is visible after clicking dropdown'
      scenario 'it logs the user in properly with good credentials'
      scenario 'it does not log the user in with bad credentials'
    end
  end
end
