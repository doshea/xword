window.cw =
  selected: null
  select_across: true
  counter: 1

  unhighlight_all = ->
    if cw.selected
      cw.selected.removeClass("selected")
      cw.selected = null
      $(".selected-word").removeClass("selected-word")
      $(".selected-clue").removeClass("selected-clue")

  highlight_next_word = ->
    clue = $(".clue.selected-clue")
    next_clue = clue.nextAll(":not(.hidden)").first()
    if next_clue.hasClass("clue")
      highlight_clue_cell(next_clue)
    else
      highlight_clue_cell clue.parent().parent().siblings(".clue-column").first().children().children().first()

  #Scrolls to selected clue
  scroll_to_selected = ->
    $sel_clue = $(".selected-clue")
    $clues = $sel_clue.closest("ol")
    top = $clues.scrollTop() + $sel_clue.position().top - $clues.height() / 2 + $sel_clue.height() / 2

    # console.log('Clues div has top at ' + $clues.scrollTop() + ' and selected clue is ' + $sel_clue.position().top + ' from the top. The div height is ' + $clues.height()/2 + ' and the clue height is ' + $sel_clue.height()/2 + ' so we scrollTo ' + top)
    $clues.stop().animate
      scrollTop: top
    , "fast"

  selected_word = ->
    letters = ""
    $.each $(".selected-word"), (index, value) ->
      letters += $(value).get_letter()
    return letters

  #highlights the word for a given cell
  word_highlight = ->
    $(".selected-word").removeClass "selected-word"
    $cell = $(".selected")
    selected_word_letters = $cell.get_word_cells()
    $.each selected_word_letters, (index, value) ->
      value.addClass "selected-word"
    select_start = $cell.get_start_cell()
    select_start.corresponding_clue().addClass "selected-clue"
    cw.scroll_to_selected()

  get_letters = ->
    letters = ""
    $cells = $(".cell")
    $.each $cells, (index, cell) ->
      letters += (if $(cell).hasClass("void") then "_" else $(cell).get_letter())
    return letters

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