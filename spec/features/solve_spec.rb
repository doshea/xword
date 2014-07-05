feature 'Solve' do
  before :each do
    create(:published_five_by_five)
  end
  context 'with anonymous user' do
    scenario '' do
      visit crossword_path(Crossword.first)
      save_and_open_page
      binding.pry
    end
  end

  context 'with logged in user' do

  end

  context 'with owner' do

  end


end