window.cw =
  selected: null
  select_across: true
  counter: 1
  editing: false

  UP : 38
  RIGHT : 39
  DOWN : 40
  LEFT : 37
  COMMAND : 91
  ENTER : 13
  SPACE : 32
  DELETE : 8
  SHIFT : 16
  TAB : 9
  BACKSPACE : 8
  HYPHEN: 189
  PAGE_NAV_KEYS: null

  # Removes highlighting from the selected cell, the selected word and the selected clue. Also sets the
  # selected boolean to false to disable keystroke events for the puzzle while it isn't in "focus"
  unhighlight_all: ->
    if cw.selected
      cw.selected.removeClass("selected")
      cw.selected = null
      $(".selected-word").removeClass("selected-word")
      $(".selected-clue").removeClass("selected-clue")

  # Looks for another clue after the currently-selected one. If there is one, highlight that clue's cell,
  # thereby highlighting the next word and the next clue. Very indirect implementation.
  highlight_next_word: ->
    clue = $(".clue.selected-clue")
    next_clue = clue.nextAll(":not(.hidden)").first()
    if next_clue.hasClass("clue")
      cw.highlight_clue_cell(next_clue)
    else
      cw.highlight_clue_cell clue.parent().parent().siblings(".clue-column").first().children().children().first() #This is highly dependent on DOM structure and sucks.

  #Scrolls to selected clue
  scroll_to_selected: ->
    $sel_clue = $(".selected-clue")
    $clues = $sel_clue.closest("ol")
    top = $clues.scrollTop() + $sel_clue.position().top - $clues.height() / 2 + $sel_clue.height() / 2

    # console.log('Clues div has top at ' + $clues.scrollTop() + ' and selected clue is ' + $sel_clue.position().top + ' from the top. The div height is ' + $clues.height()/2 + ' and the clue height is ' + $sel_clue.height()/2 + ' so we scrollTo ' + top)
    $clues.stop().animate
      scrollTop: top
    , "fast"

  # Returns all of the letters of the selected word in order
  selected_word: ->
    letters = ""
    $.each $(".selected-word"), (index, value) ->
      letters += $(value).get_letter()
    return letters

  # Highlights all of the cells in the selected cell's word, highlights the corresponding clue,
  # and scrolls the clue column to that clue
  word_highlight: ->
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
  get_letters: ->
    letters = ""
    $cells = $(".cell")
    $.each $cells, (index, cell) ->
      letters += (if $(cell).hasClass("void") then "_" else $(cell).get_letter())
    return letters


  #Intelligently sets the numbers of each cell in the crossword by calling the number_cell function
  number_cells: ->
    cw.counter = 1
    $cells = $(".cell:not(.void)")
    $.each $cells, (index, value) ->
      cw.number_cell $(value)

    counter = 1

  #Numbers cells if they are the lefmost or topmost cell in a word
  number_cell: ($cell) ->
    if not $cell.has_above() or not $cell.has_left()
      $cell.set_number cw.counter
      $cell.attr "data-cell", cw.counter #no idea why this won't work when I use the .data() method...
      cw.counter += 1
    else unless $cell.get_number() is " "
      $cell.set_number ""
      $cell.removeAttr "data-cell"

  #Keyboard Function triggered by
  keypress : (e) ->
    #in edit pages also had the following JS: if (!(e.ctrlKey || e.altKey || e.metaKey) && (selected && ($(':focus').length == 0)))
    if not (e.ctrlKey or e.altKey or e.metaKey) and (cw.selected and ($(":focus").length is 0))
      key = e.which
      switch key
        when cw.UP
          if cw.selected
            if cw.selected.cell_above()
              cw.selected.cell_above().highlight()
            else
              cw.selected.get_col_end().highlight()
        when cw.RIGHT
          if cw.selected
            if cw.selected.cell_to_right()
              cw.selected.cell_to_right().highlight()
            else
              cw.selected.get_row_beginning().highlight()
        when cw.DOWN
          if cw.selected
            if cw.selected.cell_below()
              cw.selected.cell_below().highlight()
            else
              cw.selected.get_col_beginning().highlight()
        when cw.LEFT
          if cw.selected
            if cw.selected.cell_to_left()
              cw.selected.cell_to_left().highlight()
            else
              cw.selected.get_row_end().highlight()
        when cw.TAB then cw.unhighlight_all()
        when cw.SHIFT then
        when cw.DELETE then
        when cw.SPACE
          cw.select_across = not cw.select_across
          $(".selected").highlight()
        else
          if cw.selected
            letter = String.fromCharCode(key)
            letter = '-' if key is cw.HYPHEN
            unless letter is cw.selected.get_letter()
              if cw.editing
                cw.selected.set_letter letter, true
                edit_app.update_unsaved()
                token = $("#crossword").data("auth-token")
                cell_id = cw.selected.data("id")
                settings =
                  dataType: "script"
                  type: "PUT"
                  url: "/cells/" + cell_id
                  data:
                    authenticity_token: token
                    cell:
                      letter: letter

                  error: ->
                    alert "Error toggling void!"
              else
                check_for_finish = cw.selected.is_empty_cell()
                cw.selected.set_letter letter, true
                cw.selected.check_finisheds()  if check_for_finish
                solve_app.update_unsaved()
            cw.selected.next_empty_cell().highlight()

  highlight_clue_cell : ($clue) ->
    $cell = if cw.editing then $(".cell[data-id='" + $clue.data('cell-id') + "']").first() else $(".cell[data-cell='" + $clue.attr("data-cell-num") + "']").first()
    cw.select_across = $clue.closest(".clues").attr("id") is "across"
    $cell.highlight()
    $clue.children('input').select() if cw.editing

  #Prevents backspace from going to previous window, prevents arrow keys and space from moving around page
  suppressBackspaceAndNav : (evt) ->
    evt = evt or window.event
    target = evt.target or evt.srcElement
    if evt.keyCode is cw.BACKSPACE and not /input|textarea/i.test(target.nodeName)
      check_for_unfinish = not cw.selected.is_empty_cell()
      cw.selected.delete_letter true
      cw.selected.uncheck_unfinisheds()  if check_for_unfinish
      return false
    false  if _.contains(cw.PAGE_NAV_KEYS, evt.keyCode) and not /input|textarea/i.test(target.nodeName)

cw.PAGE_NAV_KEYS = [cw.UP, cw.RIGHT, cw.DOWN, cw.LEFT, cw.SPACE]
document.onkeydown = cw.suppressBackspaceAndNav
document.onkeypress = cw.suppressBackspaceAndNav


#------------------
# DOCUMENT LOAD
#------------------
$ ->
  cw.number_cells() unless cw.editing
  $(document).on("keydown", cw.keypress)
  $(".cell").on "click", (e) ->
    e.stopPropagation()
    $(this).highlight()

  $(".clue").on "click", (e) ->
    e.stopPropagation()
    cw.highlight_clue_cell $(this)

  cw.selected = $(".cell:not(.void)").first()
  cw.selected.highlight()