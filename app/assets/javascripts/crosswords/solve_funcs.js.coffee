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
  crossword_id: null
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
    # $('#show-incorrect').on('click', solve_app.show_incorrect)
    $('#check-cell').on('click', solve_app.check_cell)
    $('#check-word').on('click', solve_app.check_word)
    $('#check-puzzle').on('click', solve_app.check_puzzle)
    $(".check-completion :not([data-dropdown='drop'])").on('click', solve_app.check_completion)
    #may be able to use $(document.activeElement) http://stackoverflow.com/questions/967096/using-jquery-to-test-if-an-input-has-focus
    $('input, textarea').on('click', -> cw.unhighlight_all()) #may need further tweaking on Edit
    solve_app.check_all_finished()
    true

  save_solution: (e) ->
    e.preventDefault() if e
    token = $('#crossword').data('auth-token')
    letters = cw.get_puzzle_letters();
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

  # show_incorrect: (e) ->
  #   e.preventDefault()
  #   solve_app.save_solution()
  #   letters = cw.get_puzzle_letters();
  #   settings =
  #     dataType: 'script'
  #     type: 'POST'
  #     url: "/solutions/#{solve_app.solution_id}/get_incorrect"
  #     data: {letters: letters}
  #   $.ajax(settings)

  check_cell: (e) ->
    e.preventDefault()
    if cw.selected
      if cw.selected.is_empty_cell()
        alert('This cell is empty.')
      else
        index = cw.selected.data('index')
        letter = cw.selected.get_letter()
        settings =
          dataType: 'script'
          type: 'POST'
          url: "/crosswords/#{solve_app.crossword_id}/check_cell"
          data: {letters: [letter], indices: []}
        settings.data.indices.push(index)
        $.ajax(settings)
        solve_app.save_solution()

  check_word: (e) ->
    e.preventDefault()
    if cw.selected
      settings =
          dataType: 'script'
          type: 'POST'
          url: "/crosswords/#{solve_app.crossword_id}/check_cell"
          data: {letters: [], indices: []}
      for cell in cw.selected.get_word_cells()
        unless cell.is_empty_cell()
          index = cell.data('index')
          letter = cell.get_letter()
          settings.data.indices.push(index)
          settings.data.letters.push(letter)
      if settings.data.letters.length == 0
        alert('The selected word is empty.')
      else
        $.ajax(settings)
        solve_app.save_solution()

  check_puzzle: (e) ->
    e.preventDefault()
    solve_app.save_solution()
    settings =
      dataType: 'script'
      type: 'POST'
      url: "/crosswords/#{solve_app.crossword_id}/check_cell"
      data: {letters: cw.get_puzzle_letters()}
    $.ajax(settings)
    solve_app.save_solution()

  check_completion: (e) ->
    e.preventDefault()
    solve_app.save_solution()
    letters = cw.get_puzzle_letters();
    settings =
      dataType: 'script'
      type: 'POST'
      url: "/crosswords/#{solve_app.crossword_id}/check_completion"
      data: {letters: letters, return_flags: return_flags}
    unless solve_app.anonymous
      settings.data['solution_id'] = solve_app.solution_id
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

