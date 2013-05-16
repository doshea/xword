window.edit_app =

  ready: ->
    $('#crossword').on('dblclick', '.cell', edit_app.toggle_void)

  toggle_void: ->
    console.log('sup')


$(document).ready(edit_app.ready)