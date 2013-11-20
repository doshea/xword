window.new_cw =
  form_spinner: null
  spin_opts:
    lines: 10 #The number of lines to draw
    length: 15 #The length of each line
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
  clever_processes: ['Reticulating splines', 'barfing']


  ready: ->
    $('form').on('submit', new_cw.generate_puzzle_overlay)

  generate_puzzle_overlay: ->
    console.log('hello1')


    $('#body .row:not(.row-bookend)').first().children().animate
      'opacity': 0
    , 'slow', ->
      unless new_cw.form_spinner
        console.log('hello2')
        target = $('.spin-target').get(0)
        new_cw.form_spinner = new Spinner(new_cw.spin_opts).spin(target)
        $('<h2>').text('Generating Puzzle').prependTo($('.spin-target'))
        $('<h6>').text(new_cw.clever_processes[0]).appendTo($('.spin-target'))

$(document).ready(new_cw.ready)