window.new_cw = {
  form_spinner: null,
  spin_opts: {
    lines: 10,
    length: 15,
    width: 4,
    radius: 6,
    corners: 1,
    rotate: 0,
    direction: 1,
    color: '#000',
    speed: 1,
    trail: 60,
    shadow: false,
    hwaccel: false,
    className: 'spinner',
    zIndex: 2e9,
    top: 'auto',
    left: 'auto'
  },
  clever_processes: ['Reticulating splines', 'barfing'],

  ready: function() {
    $('form').on('submit', new_cw.generate_puzzle_overlay);
    $('#crossword_rows, #crossword_cols').on('change', new_cw.regenerate_preview);
    $('#preview-crossword').on('mousedown', '.preview-cell', function() {
      $(this).toggleClass('void');
    });
    new_cw.hide_extra_cells();
  },

  generate_puzzle_overlay: function() {
    $('#body .row:not(.row-bookend)').first().children().animate(
      { 'opacity': 0 },
      'slow',
      function() {
        if (!new_cw.form_spinner) {
          var target = $('.spin-target').get(0);
          new_cw.form_spinner = new Spinner(new_cw.spin_opts).spin(target);
          $('<h2>').text('Generating Puzzle').prependTo($('.spin-target'));
          $('<h6>').text(new_cw.clever_processes[0]).appendTo($('.spin-target'));
        }
      }
    );
  },

  regenerate_preview: function() {
    $('.preview-cell').show();
    new_cw.hide_extra_cells();
  },

  hide_extra_cells: function() {
    var rows = $('#crossword_rows').val();
    var cols = $('#crossword_cols').val();
    var extra_cells = $('.preview-cell').filter(function() {
      return ($(this).data('col') > cols) || ($(this).data('row') > rows);
    });
    extra_cells.hide();
  }
};

// Use turbo:load so new_cw.ready() runs after Turbo Drive replaces the body.
// Remove+re-add to prevent duplicate listeners if the script re-executes.
if (window._newCwTurboLoadHandler) document.removeEventListener("turbo:load", window._newCwTurboLoadHandler);
window._newCwTurboLoadHandler = function() {
  if (!$('#preview-crossword').length) return; // not on the new crossword page
  new_cw.ready();
};
document.addEventListener("turbo:load", window._newCwTurboLoadHandler);
// Body script may execute after turbo:load has already fired — run immediately if DOM ready.
if (document.readyState !== 'loading' && $('#preview-crossword').length) {
  new_cw.ready();
}
