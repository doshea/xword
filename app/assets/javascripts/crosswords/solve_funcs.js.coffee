###
Crossword Solving Functions
---------------------------
This file defines functions used only by the site's Javascript-based
crossword solver. Functions are scoped inside of the 'solve.app'
variable, with the exception of jQuery custom functions which may
be called by any jQuery object.
###

window.solve_app =
  logged_in: null
  solution_id: null
  save_timer: null
  clock_updater: null
  last_save: null
  unsaved_changes: false

  ready: ->
    unless solve_app.anonymous
      solve_app.save_timer = window.setInterval(->
        solve_app.save_solution() if solve_app.unsaved_changes
      , 5000)
      solve_app.clock_updater = window.setInterval(solve_app.update_clock, 10000)
      $('#comments').on('keypress', '.reply-content', solve_app.add_comment_or_reply)
      $('#comments').on('click', '.reply-button.reply', solve_app.toggle_reply_form)
      $('#solve-save').on('click', solve_app.save_solution)
      $('#add-comment').on('keypress', solve_app.add_comment_or_reply)
      $('.cancel-button').on('click', solve_app.toggle_reply_form)
    $('#controls-button').on('click', (e) -> 
      e.preventDefault()
      $('#controls-modal').foundation('reveal', 'open')
    )
    $('#show-incorrect').on('click', solve_app.show_incorrect)
    $('#check-correctness').on('click', solve_app.check_correctness)
    $(':not(.cell, .cell *, .clue, .clue *)').on('click', -> cw.unhighlight_all())
    solve_app.check_all_finished()
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
    if solve_app.last_save and not solve_app.anonymous
      $('#save-status').text('Saved ')
      $('#save-clock').text(moment(solve_app.last_save).fromNow())

  update_unsaved: ->
    unless solve_app.anonymous
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
    e.preventDefault() if e
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

# jQuery solving functions
(($) ->
  $.fn.delete_letter = (original) ->
    if @is_empty_cell()
      unless @is_word_start()
        unless @previous_cell().is_empty_cell()
          @previous_cell().delete_letter true
          solve_app.update_unsaved()
        @previous_cell().highlight()
        false
    else
      @children(".letter").first().empty()
      unless typeof team_app is "undefined"
        if original
          team_app.send_team_cell this, ""
        else
          @uncheck_unfinisheds()
      solve_app.update_unsaved()
) jQuery

$(document).ready(solve_app.ready)

