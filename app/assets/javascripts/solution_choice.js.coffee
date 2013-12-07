draw_letters = ($row) ->
  cols = 15
  key = $row.data("key")
  hidden_canvas = $("canvas#letters_" + key).get(0)
  unless hidden_canvas
    hidden_canvas = $("<canvas class='hidden-canvas' id='letters_" + key + "'>")
    console.log "Made a hidden canvas!"
    $row.children(":first-child").append hidden_canvas
    main_canvas = $("canvas[id^=\"crossword\"]")
    left_corner_x = main_canvas.offset().left + 1
    left_corner_y = main_canvas.offset().top + 1
    hidden_canvas.width main_canvas.width()
    hidden_canvas.height main_canvas.height()
    hidden_canvas.offset
      top: left_corner_y
      left: left_corner_x

    temp_context = hidden_canvas.get(0).getContext("2d")
    letters = $row.data("letters")
    temp_context.font = "bold 10px Helvetica Neue"
    letter_array = []
    while letters.length > 0
      letter_array.push letters.substr(0, cols)
      letters = letters.substr(cols)
    letter_array.each (string, row) ->
      string.each (char, col) ->
        if (char isnt " ") and (char isnt "_")
          x = ((if (col is 0) then 2.5 else 3.5 + 10 * col)) * 2
          y = (if (row is 0) then 7.5 else 10 + 10 * row)
          temp_context.fillText char, x, y


$("tbody").on "click", "tr td:not(.delete-td)", (e) ->
  e.preventDefault()
  window.location = $(this).parent().data("link")

$("tbody tr").each (index, el) ->
  draw_letters $(el)