window.edit_app =

  ready: ->
    $('#crossword').on('dblclick', '.cell', edit_app.toggle_void)

  toggle_void: ->
    token = $('#crossword').data('auth-token')
    cell_id = $(this).data('id')
    settings =
      dataType: 'script'
      type: 'PUT'
      url: "/cells/#{cell_id}/toggle_void"
      data: {authenticity_token: token}
    $.ajax(settings)
    console.log('sup')


$(document).ready(edit_app.ready)