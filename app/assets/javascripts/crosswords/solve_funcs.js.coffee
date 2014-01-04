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
    $('#show-incorrect').on('click', solve_app.show_incorrect)
    $('#check-correctness').on('click', solve_app.check_correctness)
    $('#submit_solution').on('click', solve_app.submit_solution)
    $('#solve-save').on('click', solve_app.save_solution)
    $(':not(.cell, .cell *, .clue, .clue *)').on('click', -> cw.unhighlight_all())
    solve_app.check_all_finished()
    $('#add-comment').on('keypress', solve_app.add_comment_or_reply)
    $('.reply-content').on('keypress', solve_app.add_comment_or_reply)
    $('.reply-button.reply').on('click', solve_app.toggle_reply_form)
    $('.cancel-button').on('click', solve_app.toggle_reply_form)
    true

  save_solution: (e) ->
    e.preventDefault() if e
    token = $('#crossword').data('auth-token')
    letters = cw.get_letters();
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
    letters = cw.get_letters();
    settings =
      dataType: 'script'
      type: 'POST'
      url: "/solutions/#{solve_app.solution_id}/get_incorrect"
      data: {letters: letters}
    $.ajax(settings)

  check_correctness: (e) ->
    e.preventDefault()
    solve_app.save_solution()
    letters = cw.get_letters();
    settings =
      dataType: 'script'
      type: 'POST'
      url: "/solutions/#{solve_app.solution_id}/check_correctness"
      data: {letters: letters}
    $.ajax(settings)

  add_comment_or_reply: (e) ->
    unless e.metaKey
      key = e.which
      if key is cw.ENTER
        e.preventDefault()
        unless $(this).val() is ''
          $('.replying').removeClass('replying')
          $(this).closest('.comment').addClass('replying')
          $(this).parent().submit()
          $(this).val('')

  toggle_reply_form: (e) ->
    e.preventDefault()
    reply_form = $(this).siblings('form')
    reply_form.toggle('fast')
    $(this).siblings('a').toggle()
    $(this).toggle()
    is_showing = (reply_form.css('opacity') < 0.5)
    if is_showing
      reply_form.children('textarea').focus()
    else
      reply_form[0].reset()


  check_all_finished: ->
    $.each $('.cell:not(.void)'), (index, cell) ->
      if !$(cell).has_left() then if $(cell).in_finished_across_word() then $(cell).corresponding_across_clue().addClass('crossed-off')
      if !$(cell).has_above() then if $(cell).in_finished_down_word() then $(cell).corresponding_down_clue().addClass('crossed-off')

$(document).ready(solve_app.ready)

