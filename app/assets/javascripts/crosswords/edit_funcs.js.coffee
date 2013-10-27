window.edit_app =
  unsaved_changes: false
  debug_mode: false
  title_spinner: null


  ready: ->
    $('#title-status').show()
    number_cells()

    $('#crossword').on('dblclick', '.cell', -> $(this).toggle_void(true))

    $('#title').on('change', edit_app.update_title)
    $('.clue').on('change', 'input', edit_app.update_clue)
    $('#description').on('change', edit_app.update_description)

    # $('.cell, .clue').on('click', (e) -> e.stopImmediatePropagation())
    $(':not(.cell, .cell *, .clue, .clue *)').on('click', -> remove_selections())

  update_clue: (e) ->
    id = $(this).parent().data('id')
    token = $('#crossword').data('auth-token')

    settings =
      dataType: 'script'
      type: 'PUT'
      url: "/clues/#{id}"
      data:
        clue:
          content: $(this).val()
        authenticity_token: token
    $.ajax(settings)


  update_title: (e) ->
    unless $('#title-status').length > 0
      spinbox = $('<i id="title-status">')
      spinbox.addClass('fi-checkmark')
      spinbox.insertAfter('#title')

    edit_app.spin_title()
    token = $('#crossword').data('auth-token')
    id = $('#crossword').data('id')
    edit_app.spin_title()

    settings =
      dataType: 'script'
      type: 'PUT'
      url: "/crosswords/#{id}"
      data:
        crossword:
          title: $('#title').val()
        authenticity_token: token
      success: ->
        $('.spinner').remove()
        $('#title-status').addClass('fi-check').removeClass('fi-x').css('color', 'black')
        $('#title-status').fadeOut(1000, -> $(this).remove())
      error: ->
        $('.spinner').remove()
        $('#title-status').addClass('fi-x').removeClass('fi-check')
        $('#title-status').fadeOut(3000, -> $(this).remove())
    $.ajax(settings)

  update_description: (e) ->
    token = $('#crossword').data('auth-token')
    id = $('#crossword').data('id')

    settings =
      dataType: 'script'
      type: 'PUT'
      url: "/crosswords/#{id}"
      data:
        crossword:
          description: $('#description').val()
        authenticity_token: token
      error: ->
        alert('Error updating title!');
    $.ajax(settings);

  update_unsaved: ->
    edit_app.unsaved_changes = true
    $('#save-status').text('Unsaved changes')
    $('#save-clock').empty()

  spin_title: ->
    $('.spinner').remove()
    opts =
      lines: 10 #The number of lines to draw
      length: 7 #The length of each line
      width: 4 #The line thickness
      radius: 6 #The radius of the inner circle
      corners: 1 #Corner roundness (0..1)
      rotate: 0 #The rotation offset
      direction: 1 #1: clockwise, -1: counterclockwise
      color: '#000' #rgb or #rrggbb
      speed: 1 #Rounds per second
      trail: 60 #Afterglow percentage
      shadow: false #Whether to render a shadow
      hwaccel: false #Whether to use hardware acceleration
      className: 'spinner' #The CSS class to assign to the spinner
      zIndex: 2e9 #The z-index (defaults to 2000000000)
      top: 'auto' #Top position relative to parent in px
      left: 'auto' #Left position relative to parent in px
    target = document.getElementById('title-status')
    edit_app.title_spinner = new Spinner(opts).spin(target)

$(document).ready(edit_app.ready)