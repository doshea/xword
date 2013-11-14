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
    $(':not(.cell, .cell *, .clue, .clue *)').on('click', -> unhighlight_all())
    solve_app.check_all_finished()
    true

  save_solution: (e) ->
    e.preventDefault() if e
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
      $('#save-status').text('Saved ')
      $('#save-clock').text(moment(solve_app.last_save).fromNow())

  update_unsaved: ->
    solve_app.unsaved_changes = true
    $('#save-status').text('Unsaved changes')
    $('#save-clock').empty()

  show_incorrect: (e) ->
    e.preventDefault()
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
    solve_app.save_solution()
    letters = get_letters();
    settings =
      dataType: 'script'
      type: 'POST'
      url: "/solutions/#{solve_app.solution_id}/check_correctness"
      data: {letters: letters}
    $.ajax(settings)

  check_all_finished: ->
    $.each $('.cell:not(.void)'), (index, cell) ->
      if !$(cell).has_left() then if $(cell).in_finished_across_word() then $(cell).corresponding_across_clue().addClass('crossed-off')
      if !$(cell).has_above() then if $(cell).in_finished_down_word() then $(cell).corresponding_down_clue().addClass('crossed-off')

$(document).ready(solve_app.ready)

