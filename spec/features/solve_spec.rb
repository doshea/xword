feature 'Solve', js: true do
  let!(:crossword) { create(:predefined_five_by_five) }

  before :each do
    visit crossword_path(crossword)
  end

  # 5×5 grid with no voids:
  #   A M I G O  (across clue 1)
  #   V O L O W  (across clue 6)
  #   A N I O N  (across clue 7)
  #   I D O S E  (across clue 8)
  #   L O N E R  (across clue 9)
  #
  # Down clues: 1(AVAIL), 2(MONDO), 3(ILION), 4(GOOSE), 5(OWNER)

  scenario 'first cell is auto-selected on page load' do
    expect(page).to have_css('td.cell[data-row="1"][data-col="1"].selected')
  end

  scenario 'clicking a cell highlights it' do
    find('td.cell[data-row="2"][data-col="3"]').click
    expect(page).to have_css('td.cell[data-row="2"][data-col="3"].selected')
  end

  scenario 'clicking a cell highlights its across word' do
    # Click cell (1,3) — part of across word AMIGO (row 1, cols 1-5)
    find('td.cell[data-row="1"][data-col="3"]').click

    # All 5 cells in row 1 should have selected-word
    (1..5).each do |col|
      expect(page).to have_css("td.cell[data-row='1'][data-col='#{col}'].selected-word")
    end
  end

  scenario 'clicking a cell highlights the corresponding across clue' do
    # Click cell (1,3) — across word starts at cell_num 1 ("A male friend")
    find('td.cell[data-row="1"][data-col="3"]').click
    expect(page).to have_css('li.across-clue[data-cell-num="1"].selected-clue')
  end

  scenario 'spacebar toggles direction to down' do
    # Click cell (1,3) to select it (across by default)
    find('td.cell[data-row="1"][data-col="3"]').click
    expect(page).to have_css('li.across-clue[data-cell-num="1"].selected-clue')

    # Press spacebar to toggle to down direction
    find('body').send_keys(:space)

    # Down clue for column 3 = clue number 3 ("Ancient Troy")
    expect(page).to have_css('li.down-clue[data-cell-num="3"].selected-clue')

    # Down word through (1,3) should be highlighted: ILION (col 3, rows 1-5)
    (1..5).each do |row|
      expect(page).to have_css("td.cell[data-row='#{row}'][data-col='3'].selected-word")
    end

    # Across clue should no longer be highlighted
    expect(page).not_to have_css('li.across-clue.selected-clue')
  end

  scenario 'clicking a down clue highlights its start cell and down word' do
    # Click down clue 2 ("A Zen question...") — starts at (1,2), word MONDO
    find('li.down-clue[data-cell-num="2"]').click

    # Start cell (1,2) should be selected
    expect(page).to have_css('td.cell[data-row="1"][data-col="2"].selected')

    # All cells in column 2 should have selected-word
    (1..5).each do |row|
      expect(page).to have_css("td.cell[data-row='#{row}'][data-col='2'].selected-word")
    end

    # The down clue should be highlighted
    expect(page).to have_css('li.down-clue[data-cell-num="2"].selected-clue')
  end

  scenario 'clicking a text input unhighlights all cells' do
    # Wait for first cell to be auto-selected
    expect(page).to have_css('td.cell.selected')

    # Click the nav search input to trigger unhighlight
    find('input.xw-nav__search-input').click

    # No cell should be selected anymore
    expect(page).not_to have_css('td.cell.selected')
    expect(page).not_to have_css('td.cell.selected-word')
    expect(page).not_to have_css('li.clue.selected-clue')
  end
end
