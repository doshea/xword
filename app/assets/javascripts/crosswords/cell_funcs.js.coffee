###
Custom jQuery Functions for Cells
-----------------------
These functions are used by both the in-site crossword solver and editor. While they can
technically be called by any jQuery object, they are intended to be called by the td.cell
elements of the table#crossword
###

(($) ->
  $.fn.get_row = ->
    @data "row"
  $.fn.get_col = ->
    @data "col"

  $.fn.is_void = ->
    @hasClass "void"

  $.fn.in_top_row = ->
    $(this).get_row() is 1
  $.fn.in_bottom_row = ->
    @get_row() is $("#crossword").data("rows")
  $.fn.in_left_col = ->
    @get_col() is 1
  $.fn.in_right_col = ->
    @get_col() is $("#crossword").data("cols")

  $.fn.get_row_beginning = ->
    row = parseInt(@get_row())
    $ ".cell[data-row=" + row + "][data-col=1]"
  $.fn.get_row_end = ->
    row = parseInt(@get_row())
    $ ".cell[data-row=" + row + "][data-col=" + $("#crossword").data("cols") + "]"
  $.fn.get_col_beginning = ->
    col = parseInt(@get_col())
    $ ".cell[data-row=1][data-col=" + col + "]"
  $.fn.get_col_end = ->
    col = parseInt(@get_col())
    $ ".cell[data-row=" + $("#crossword").data("rows") + "][data-col=" + col + "]"

  
  # Return booleans indicating whether there is a cell adjacent to the one calling the function and whether it is non-void
  # TODO: Determine whether this is redundant with the "cell_to_left" series of functions
  $.fn.has_above = ->
    if @in_top_row()
      false
    else
      row = parseInt(@get_row())
      col = parseInt(@get_col())
      above = $(".cell[data-row='" + (row - 1) + "'][data-col='" + col + "']")
      not above.is_void()
  $.fn.has_below = ->
    if @in_bottom_row()
      false
    else
      row = parseInt(@get_row())
      col = parseInt(@get_col())
      below = $(".cell[data-row='" + (row + 1) + "'][data-col='" + col + "']")
      not below.is_void()
  $.fn.has_left = ->
    if @in_left_col()
      false
    else
      row = parseInt(@get_row())
      col = parseInt(@get_col())
      left = $(".cell[data-row='" + row + "'][data-col='" + (col - 1) + "']")
      not left.is_void()
  $.fn.has_right = ->
    if @in_right_col()
      false
    else
      row = parseInt(@get_row())
      col = parseInt(@get_col())
      right = $(".cell[data-row='" + row + "'][data-col='" + (col + 1) + "']")
      not right.is_void()

  
  # Returns the jQuery object of the adjacent cell
  $.fn.cell_to_left = ->
    if @in_left_col()
      false
    else
      left_cell = @prevAll(".cell:not(.void)").first()
      if left_cell.get(0)
        left_cell
      else
        false
  $.fn.cell_to_right = ->
    if @in_right_col()
      false
    else
      right_cell = @nextAll(".cell:not(.void)").first()
      if right_cell.get(0)
        right_cell
      else
        false
  $.fn.cell_above = ->
    if @in_top_row()
      false
    else
      row = parseInt(@get_row())
      col = parseInt(@get_col())
      above = $(".cell[data-row='" + (row - 1) + "'][data-col='" + col + "']")
      unless above.is_void()
        above
      else
        above.cell_above()
  $.fn.cell_below = ->
    if @in_bottom_row()
      false
    else
      row = parseInt(@get_row())
      col = parseInt(@get_col())
      below = $(".cell[data-row='" + (row + 1) + "'][data-col='" + col + "']")
      unless below.is_void()
        below
      else
        below.cell_below()
  
  $.fn.previous_cell = ->
    if cw.select_across then @cell_to_left() else @cell_above()
  $.fn.next_cell = ->
    if cw.select_across then @cell_to_right() else @cell_below()

  $.fn.is_word_start = ->
    not (if cw.select_across then @has_left() else @has_above())
  $.fn.is_word_end = ->
    not ((if cw.select_across then @has_right() else @has_below()))

  $.fn.get_down_word_cells = ->
    @get_down_start_cell().down_word_from_start()
  $.fn.get_down_start_cell = ->
    unless @has_above()
      this
    else
      @cell_above().get_down_start_cell()
  $.fn.get_down_end_cell = ->
    unless @has_below()
      this
    else
      @cell_below().get_down_end_cell()
  $.fn.down_word_from_start = ->
    unless @has_below()
      [this]
    else
      [this].concat @cell_below().down_word_from_start()
  $.fn.get_down_word = ->
    $.map(@get_down_word_cells(), (el, i) ->
      el.text()
    ).join ""

  $.fn.get_across_word_cells = ->
    @get_across_start_cell().across_word_from_start()
  $.fn.get_across_start_cell = ->
    unless @has_left()
      this
    else
      @cell_to_left().get_across_start_cell()
  $.fn.get_across_end_cell = ->
    unless @has_right()
      this
    else
      @cell_to_right().get_across_end_cell()
  $.fn.across_word_from_start = ->
    unless @has_right()
      [this]
    else
      [this].concat @cell_to_right().across_word_from_start()
  $.fn.get_across_word = ->
    $.map(@get_across_word_cells(), (el, i) ->
      el.text()
    ).join ""

  $.fn.get_word_cells = ->
    (if cw.select_across then @get_across_word_cells() else @get_down_word_cells())

  $.fn.word_from_start = ->
    (if cw.select_across then @across_word_from_start() else @down_word_from_start())

  $.fn.get_start_cell = ->
    (if cw.select_across then @get_across_start_cell() else @get_down_start_cell())

  $.fn.get_end_cell = ->
    (if cw.select_across then @get_across_end_cell() else @get_down_end_cell())

  
  # Both a td.cell's number (if any) and its letter are stored as child divs, and these functions get and set these values
  $.fn.get_number = ->
    letter = @children(".cell-num").text()
    (if letter.length > 0 then letter else " ")

  $.fn.set_number = (number) ->
    @children(".cell-num").text number
    return

  $.fn.get_letter = ->
    letter = @children(".letter").first().text().replace(/\n/g, "").replace(RegExp("  +", "g"), "")
    (if letter.length > 0 then letter else " ")

  $.fn.set_letter = (letter, original) ->
    @children(".letter").first().text letter
    unless typeof team_app is "undefined"
      if original
        team_app.send_team_cell this, letter
      else
        @check_finisheds()
    return

  $.fn.is_last_letter_of_puzzle = ->
    word_cells = ((if cw.select_across then @get_across_word_cells() else @get_down_word_cells()))
    last_index = word_cells.length - 1
    this[0] is word_cells[last_index][0]

  $.fn.is_empty_cell = ->
    (@get_letter() is "") or (@get_letter() is " ") or (@get_letter().replace(/\n/g, "").replace(RegExp("  +", "g"), " ") is " ")

  $.fn.corresponding_across_clue = ->
    (if @data('cell') then $(".across-clue[data-cell-num=" + @data('cell') + "]") else $(".across-clue[data-index=" + @data('index') + "]"))

  $.fn.corresponding_down_clue = ->
    (if @data('cell') then $(".down-clue[data-cell-num=" + @data('cell') + "]") else $(".down-clue[data-index=" + @data('index') + "]"))

  $.fn.corresponding_clue = ->
    (if cw.select_across then @corresponding_across_clue() else @corresponding_down_clue())
  
  # Highlights this cell as the current cell in which the user is typing, unhighlights all other cells, and highlights the word this cell is in
  $.fn.highlight = ->
    if @hasClass("cell") and not @is_void()
      cw.unhighlight_all()
      cw.selected = this
      @addClass "selected"
      cw.word_highlight()
    return

  
  # 
  $.fn.in_finished_across_word = ->
    cells = @get_across_word_cells()
    is_finished = true
    i = 0
    while i < cells.length
      if cells[i].is_empty_cell()
        is_finished = false
        break
      i++
    is_finished

  $.fn.in_finished_down_word = ->
    cells = @get_down_word_cells()
    is_finished = true
    i = 0
    while i < cells.length
      if cells[i].is_empty_cell()
        is_finished = false
        break
      i++
    is_finished

  $.fn.in_finished_word = ->
    cells = @get_word_cells()
    is_finished = true
    i = 0
    while i < cells.length
      if cells[i].is_empty_cell()
        is_finished = false
        break
      i++
    is_finished

  $.fn.in_directional_finished_word = ->
    (if cw.select_across then @in_finished_across_word() else @in_finished_down_word())

  
  # These functions are a bit unusual as they only function for the starting cells of words
  $.fn.check_finisheds = ->
    @get_across_start_cell().corresponding_across_clue().addClass "crossed-off"  if @in_finished_across_word()
    @get_down_start_cell().corresponding_down_clue().addClass "crossed-off"  if @in_finished_down_word()
    return

  $.fn.uncheck_unfinisheds = ->
    @get_across_start_cell().corresponding_across_clue().removeClass "crossed-off"
    @get_down_start_cell().corresponding_down_clue().removeClass "crossed-off"
    return

  $.fn.next_empty_cell_in_word = ->
    (if (@is_word_end() or @is_empty_cell()) then this else @next_cell().next_empty_cell_in_word())

  $.fn.next_empty_cell = ->
    if @is_last_letter_of_puzzle()
      if @is_empty_cell()
        this
      else
        cw.highlight_next_word()
        (if $(".selected").is_empty_cell() then $(".selected") else $(".selected").next_empty_cell())  unless $(".selected").get_number() is 1
    else
      next = @next_cell()
      (if next.is_empty_cell() then next else next.next_empty_cell())

  return
) jQuery