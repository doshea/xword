window.new_cw = {
  overlayShown: false,

  ready: function() {
    $('form').on('submit', new_cw.generate_puzzle_overlay);
    $('#unpublished_crossword_rows, #unpublished_crossword_cols').on('change', new_cw.regenerate_preview);
    new_cw.hide_extra_cells();
  },

  generate_puzzle_overlay: function() {
    if (new_cw.overlayShown) return;
    new_cw.overlayShown = true;

    var $target = $('.spin-target');
    $target.children().animate({ 'opacity': 0 }, 'slow', function() {
      // Only inject once (jQuery animate calls callback per matched element)
      if ($target.find('.xw-newcw-overlay').length) return;

      var overlay = $(
        '<div class="xw-newcw-overlay">' +
          '<div class="xw-spinner xw-newcw-overlay__spinner"></div>' +
          '<p class="xw-newcw-overlay__text">Creating puzzle\u2026</p>' +
        '</div>'
      );
      $target.append(overlay);
    });
  },

  regenerate_preview: function() {
    $('.preview-cell').show();
    new_cw.hide_extra_cells();
  },

  hide_extra_cells: function() {
    var rows = $('#unpublished_crossword_rows').val();
    var cols = $('#unpublished_crossword_cols').val();
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
  new_cw.overlayShown = false;
  new_cw.ready();
};
document.addEventListener("turbo:load", window._newCwTurboLoadHandler);
// Body script may execute after turbo:load has already fired — run immediately if DOM ready.
if (document.readyState !== 'loading' && $('#preview-crossword').length) {
  new_cw.ready();
}
