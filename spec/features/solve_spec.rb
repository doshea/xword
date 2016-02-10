feature 'Solve' do
  before :each do
    create(:predefined_five_by_five)
    visit crossword_path(Crossword.first)
  end
  context 'with anonymous user' do
    scenario 'arrives on the page' do
      current_path.should eq crossword_path(Crossword.first)
    end
    
  end

  context 'with logged in user' do

  end

  context 'with owner' do

  end


end