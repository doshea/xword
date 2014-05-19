feature 'Login' do
  scenario 'Anonymous user logs in from home page' do
    visit root_path
    click_link 'Log In'
  end
end