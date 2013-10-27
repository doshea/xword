window.solve_app =
  solution_id: null
  save_timer: null
  clock_updater: null
  last_save: null
  unsaved_changes: false
  debug_mode: false

  ready: ->
    solve_app.save_timer = window.setInterval(->
      solve_app.save_solution() if solve_app.unsaved_changes
    , 5000)
    solve_app.clock_updater = window.setInterval(solve_app.update_clock, 10000)
    $('#show_incorrect').on('click', solve_app.show_incorrect)
    $('#check_correctness').on('click', solve_app.check_correctness)
    $('#submit_solution').on('click', solve_app.submit_solution)
    $('#solve-save').on('click', solve_app.save_solution)

  save_solution: (e) ->
    e.preventDefault() if e
    console.log('Saved') if solve_app.debug_mode
    token = $('#crossword').data('auth-token')
    letters = get_letters();
    settings =
      dataType: 'script'
      type: 'PUT'
      url: "/solutions/#{solve_app.solution_id}"
      data: {authenticity_token: token, letters: letters}
    $.ajax(settings)

  log_save: ->
    solve_app.last_save = moment().format("dddd, MMMM Do YYYY, h:mm:ss a")
    solve_app.unsaved_changes = false

  update_clock: ->
    if solve_app.last_save
      console.log('Updated clock text') if solve_app.debug_mode
      $('#save-status').text('Saved ')
      $('#save-clock').text(moment(solve_app.last_save).fromNow())

  update_unsaved: ->
    solve_app.unsaved_changes = true
    $('#save-status').text('Unsaved changes')
    $('#save-clock').empty()

  show_incorrect: (e) ->
    e.preventDefault()
    console.log('showing incorrect...') if solve_app.debug_mode
    solve_app.save_solution()
    letters = get_letters();
    settings =
      dataType: 'script'
      type: 'POST'
      url: "/solutions/#{solve_app.solution_id}/get_incorrect"
      data: {letters: letters}
    $.ajax(settings)

  check_correctness: (e) ->
    e.preventDefault()
    console.log('checking correctness...') if solve_app.debug_mode
    solve_app.save_solution()
    letters = get_letters();
    settings =
      dataType: 'script'
      type: 'POST'
      url: "/solutions/#{solve_app.solution_id}/check_correctness"
      data: {letters: letters}
    $.ajax(settings)

$(document).ready(solve_app.ready)

