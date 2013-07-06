window.edit_app =

  ready: ->
    number_cells()

    $('#crossword').on('dblclick', '.cell', edit_app.toggle_void)

  toggle_void: ->
    # Front-end visual toggling
    $(this).toggleClass('void')
    number_cells()

    # Back-end data toggling
    token = $('#crossword').data('auth-token')
    cell_id = $(this).data('id')
    settings =
      dataType: 'script'
      type: 'PUT'
      url: "/cells/#{cell_id}/toggle_void"
      data: {authenticity_token: token}
      error: ->
        alert('Error toggling void!')
    $.ajax(settings)


$(document).ready(edit_app.ready)