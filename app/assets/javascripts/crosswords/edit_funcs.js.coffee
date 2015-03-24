###
Crossword Editing Functions
---------------------------
This file defines functions used only by the site's Javascript-based
crossword editor. Functions are scoped inside of the 'solve.app'
variable, with the exception of jQuery custom functions which may
be called by any jQuery object.
###

cw.editing = true

window.edit_app =
  unsaved_changes: false
  save_timer: null
  last_save: null
  SAVE_INTERVAL: 15000
  title_spinner: null
  mirror_voids: true
  save_counter: null

  ready: ->
    edit_app.save_timer = window.setInterval(->
      edit_app.save_puzzle() if edit_app.unsaved_changes
    , edit_app.SAVE_INTERVAL)
    $('#title-status').show()

    $('#crossword').on('dblclick', '.cell', -> $(this).toggle_void(true))
    $('#edit-save').on('click', edit_app.save_puzzle)
    $('#title').on('change', edit_app.update_title)
    $('.clue').on('change', 'input', edit_app.update_clue)
    $('.clue').on('click', -> $(".cell[data-index=#{$(this).data('index')}]").highlight();)
    $('#description').on('change', edit_app.update_description)

    # $('.switch-form').on('click','label', -> console.log($(this));console.log('hi');console.log($("input[type='checkbox'").val());)
    $('.switch-form input').on('click', (e) -> $(this).parent().toggleClass('on off'))
    # $('.cell, .clue').on('click', (e) -> e.stopImmediatePropagation())
    $(':not(.cell, .cell *, .clue, .clue *)').on('click', -> cw.unhighlight_all())
    # $('#tools').draggable({ containment: "body"})

    $('#ideas input[name=word]').on('keypress', edit_app.add_potential_word)
    $('#settings-button').on('click', -> $('#edit-settings').foundation('reveal', 'open'))
    $('.bottom-button').on('click', -> $(this).closest('.slide-up-container').toggleClass('open'))

  add_potential_word: (e) ->
    unless e.metaKey
      key = e.which
      if key is cw.ENTER
        e.preventDefault()
        unless $(this).val() is ''
          $(this).parent().submit()

  update_clue: (e) ->
    edit_app.update_unsaved()

  update_title: (e) ->
    title_status = $('#title-status')
    title_status.css('opacity', 1)

    token = $('#crossword').data('auth-token')
    id = $('#crossword').data('id')

    settings =
      dataType: 'script'
      type: 'PUT'
      url: "/unpublished_crosswords/#{id}"
      data:
        unpublished_crossword:
          title: $('#title').val()
        authenticity_token: token
      success: ->
        title_status.addClass('fi-check').removeClass('fi-x')
      error: ->
        title_status.addClass('fi-x').removeClass('fi-check')
      complete: ->
        title_status.fadeTo 1500,0, ->
          title_status.removeClass('fi-check fi-x')
    $.ajax(settings)

  update_description: (e) ->
    token = $('#crossword').data('auth-token')
    id = $('#crossword').data('id')

    settings =
      dataType: 'script'
      type: 'PUT'
      url: "/unpublished_crosswords/#{id}"
      data:
        unpublished_crossword:
          description: $('#description').val()
        authenticity_token: token
      error: ->
        alert('Error updating title!');
    $.ajax(settings);

  update_unsaved: ->
    edit_app.unsaved_changes = true
    edit_app.save_counter = Math.random().toString()
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

  number_clues: ->
    $('.clue').each -> 
      clue_num = $(this).children('.clue-num')
      cell_index = $(this).data('index')
      cell_num = parseInt($(".cell[data-index=#{cell_index}]").first().attr('data-cell'))
      clue_num.text("#{cell_num}.")

  save_puzzle: (e) ->
    letters_array = []
    $cells = $('.cell')
    $.each $cells, (i, cell) ->
      if $(cell).is_void()
        letters_array[i] = 0
      else
        letters_array[i] = $(cell).get_letter()

    across_clues = []
    down_clues = []
    $.each $('.across-clue'), -> 
      across_clues.push $(this).children('input').val()
    $.each $('.down-clue'), -> 
      down_clues.push $(this).children('input').val() 

    token = $('#crossword').data('auth-token')
    id = $('#crossword').data('id')
    settings =
      dataType: 'script'
      contentType: 'application/json'
      type: 'PATCH'
      url: "/unpublished_crosswords/#{id}/update_letters"
      data: JSON.stringify({letters: letters_array, across_clues: across_clues, down_clues: down_clues, authenticity_token: token, save_counter: edit_app.save_counter}) #JSON monkey businesses required to get non-string values into this array
      success: ->
        console.log('Saved!')
      error: ->
        alert('Error updating letters!');
    console.log('Saving...')
    $.ajax(settings);
    
  log_save: ->
    edit_app.last_save = moment().format("dddd, MMMM Do YYYY, h:mm:ss a")
    edit_app.unsaved_changes = false

  update_clock: ->
    if edit_app.last_save
      $('#save-status').text('Saved ')
      $('#save-clock').text(moment(edit_app.last_save).fromNow())

# jQuery editing functions
(($) ->
  $.fn.corresponding_clues = ->
    $ ".clue[data-index=" + @data("index") + "]"

  $.fn.delete_letter = (letter) ->
    @children(".letter").first().empty()
  #   token = $("#crossword").data("auth-token")
  #   cell_id = @data("id")
  #   settings =
  #     dataType: "script"
  #     type: "PUT"
  #     url: "/cells/" + cell_id
  #     data:
  #       authenticity_token: token
  #       cell:
  #         letter: ""
  #     error: ->
  #       alert "Error toggling void!"
  #   $.ajax settings

  $.fn.get_mirror_cell = ->
    $cells = $(".cell")
    cell_count = $cells.length
    this_index = $.inArray(this[0], $cells)
    $ $cells[cell_count - this_index - 1]

  $.fn.toggle_void = (recursive) ->

    #Makes this cell void
    @set_letter ''
    @toggleClass 'void'

    #if this cell was made void, hides its clues and shows any clues below and right
    if @hasClass('void')
      @corresponding_clues().hide()
      @cell_below().corresponding_clues().filter(".down-clue").show() if @has_below()
      @cell_to_right().corresponding_clues().filter(".across-clue").show() if @has_right()
    else
      #Otherwise, hides clues below and right and possibly shows this cell's clues

      @cell_below().corresponding_clues().filter(".down-clue").hide() if @has_below()
      @cell_to_right().corresponding_clues().filter(".across-clue").hide() if @has_right()
      @corresponding_clues().filter(".down-clue").show()  unless @cell_above()
      @corresponding_clues().filter(".across-clue").show()  unless @cell_to_left()

    if recursive and edit_app.mirror_voids
      mirror_cell = @get_mirror_cell()
      unless this[0] is mirror_cell[0]
        mirror_cell.toggle_void(false)

    if recursive
      next_cell = if cw.select_across then @cell_to_right() else @cell_below()
      next_cell.highlight()
    cw.number_cells()
    edit_app.number_clues()
    edit_app.update_unsaved()
) jQuery

$(document).ready(edit_app.ready)