window.app =
  solution_id: null
  save_timer: null
  clock_updater: null
  last_save: null
  unsaved_changes: false
  debug_mode: false

  ready: ->
    app.save_timer = window.setInterval(->
      app.save_solution() if app.unsaved_changes
    , 5000)
    app.clock_updater = window.setInterval(app.update_clock, 10000)
    $('#show_incorrect').on('click', app.show_incorrect)
    $('#check_correctness').on('click', app.check_correctness)
    $('#submit_solution').on('click', app.submit_solution)

  save_solution: ->
    console.log('Saved') if app.debug_mode
    token = $('#crossword').data('auth-token')
    letters = get_letters();
    settings =
      dataType: 'script'
      type: 'PUT'
      url: "/solutions/#{app.solution_id}"
      data: {authenticity_token: token, letters: letters}
    $.ajax(settings)

  log_save: ->
    app.last_save = moment().format("dddd, MMMM Do YYYY, h:mm:ss a")
    app.unsaved_changes = false

  update_clock: ->
    if app.last_save
      console.log('Updated clock text') if app.debug_mode
      $('#save_status').text('Saved ')
      $('#save_clock').text(moment(app.last_save).fromNow())

  update_unsaved: ->
    app.unsaved_changes = true
    $('#save_status').text('Unsaved changes')
    $('#save_clock').empty()

  show_incorrect: (e) ->
    e.preventDefault()
    console.log('showing incorrect...') if app.debug_mode
    app.save_solution()
    letters = get_letters();
    settings =
      dataType: 'script'
      type: 'POST'
      url: "/solutions/#{app.solution_id}/get_incorrect"
      data: {letters: letters}
    $.ajax(settings)

  check_correctness: (e) ->
    e.preventDefault()
    console.log('checking correctness...') if app.debug_mode
    app.save_solution()
    letters = get_letters();
    settings =
      dataType: 'script'
      type: 'POST'
      url: "/solutions/#{app.solution_id}/check_correctness"
      data: {letters: letters}
    $.ajax(settings)

$(document).ready(app.ready)

