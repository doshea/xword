window.edit_app =

  ready: ->
    number_cells()

    $('#crossword').on('dblclick', '.cell', ->
      $(this).toggle_void(true)
    )

  update_unsaved: ->
    console.log('this still does nothing')

$(document).ready(edit_app.ready)