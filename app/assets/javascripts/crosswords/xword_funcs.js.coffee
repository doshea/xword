window.cw =
  selected: null
  select_across: true
  counter: 1

  # Removes highlighting from the selected cell, the selected word and the selected clue. Also sets the
  # selected boolean to false to disable keystroke events for the puzzle while it isn't in "focus"
  unhighlight_all = ->
    if cw.selected
      cw.selected.removeClass("selected")
      cw.selected = null
      $(".selected-word").removeClass("selected-word")
      $(".selected-clue").removeClass("selected-clue")

  # Looks for another clue after the currently-selected one. If there is one, highlight that clue's cell,
  # thereby highlighting the next word and the next clue. Very indirect implementation.
  highlight_next_word = ->
    clue = $(".clue.selected-clue")
    next_clue = clue.nextAll(":not(.hidden)").first()
    if next_clue.hasClass("clue")
      highlight_clue_cell(next_clue)
    else
      highlight_clue_cell clue.parent().parent().siblings(".clue-column").first().children().children().first() #This is highly dependent on DOM structure and sucks.

  #Scrolls to selected clue
  scroll_to_selected = ->
    $sel_clue = $(".selected-clue")
    $clues = $sel_clue.closest("ol")
    top = $clues.scrollTop() + $sel_clue.position().top - $clues.height() / 2 + $sel_clue.height() / 2

    # console.log('Clues div has top at ' + $clues.scrollTop() + ' and selected clue is ' + $sel_clue.position().top + ' from the top. The div height is ' + $clues.height()/2 + ' and the clue height is ' + $sel_clue.height()/2 + ' so we scrollTo ' + top)
    $clues.stop().animate
      scrollTop: top
    , "fast"

  # Returns all of the letters of the selected word in order
  selected_word = ->
    letters = ""
    $.each $(".selected-word"), (index, value) ->
      letters += $(value).get_letter()
    return letters

  # Highlights all of the cells in the selected cell's word, highlights the corresponding clue,
  # and scrolls the clue column to that clue
  word_highlight = ->
    $(".selected-word").removeClass "selected-word"
    $cell = $(".selected")
    selected_word_letters = $cell.get_word_cells()
    $.each selected_word_letters, (index, value) ->
      value.addClass "selected-word"
    select_start = $cell.get_start_cell()
    select_start.corresponding_clue().addClass "selected-clue"
    cw.scroll_to_selected()

  # Returns all of the letters of the puzzle in order, with voids replaced by underscores
  # EX: FOO_BAR...
  get_letters = ->
    letters = ""
    $cells = $(".cell")
    $.each $cells, (index, cell) ->
      letters += (if $(cell).hasClass("void") then "_" else $(cell).get_letter())
    return letters

#------------------
# DOCUMENT LOAD
#------------------
$ ->
  $(document).on("keydown", crossword_keypress)
  $(".cell").on "click", (e) ->
    e.stopPropagation()
    $(this).highlight()

  $(".clue").on "click", (e) ->
    e.stopPropagation()
    highlight_clue_cell $(this)

  cw.selected = $(".cell:not(.void)").first()
  cw.selected.highlight()