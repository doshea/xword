window.cw = {
  selected: null,
  select_across: true,
  counter: 1,
  editing: false,

  UP: 38,
  RIGHT: 39,
  DOWN: 40,
  LEFT: 37,
  COMMAND: 91,
  ENTER: 13,
  SPACE: 32,
  DELETE: 8,
  SHIFT: 16,
  TAB: 9,
  ESCAPE: 27,
  BACKSPACE: 8,
  HYPHEN: 189,

  // Removes highlighting from the selected cell, word, and clue.
  unhighlight_all: function(e) {
    if (cw.selected) {
      cw.selected.removeClass("selected");
      cw.selected = null;
      $(".selected-word").removeClass("selected-word");
      $(".selected-clue").removeClass("selected-clue");
    }
  },

  // Looks for the next clue after the currently-selected one and highlights it.
  highlight_next_word: function() {
    var clue = $(".clue.selected-clue");
    var next_clue = clue.nextAll(":not(.hidden)").first();
    if (next_clue.hasClass("clue")) {
      cw.highlight_clue_cell(next_clue);
    } else {
      cw.highlight_clue_cell(clue.parent().parent().siblings(".clue-column").first().children().children().first());
    }
  },

  // Scrolls to the selected clue
  scroll_to_selected: function() {
    var $sel_clue = $(".selected-clue");
    var $clues = $sel_clue.closest("ol");
    var top = $clues.scrollTop() + $sel_clue.position().top - $clues.height() / 2 + $sel_clue.height() / 2;
    $clues.stop().animate({ scrollTop: top }, 100);
  },

  // Returns all of the letters of the selected word in order
  selected_word: function() {
    var letters = '';
    $.each($('.selected-word'), function(index, value) {
      letters += $(value).get_letter();
    });
    return letters;
  },

  // Highlights all cells in the selected cell's word and the corresponding clue
  word_highlight: function() {
    $(".selected-word").removeClass("selected-word");
    var $cell = $(".selected");
    var selected_word_letters = $cell.get_word_cells();
    $.each(selected_word_letters, function(index, value) {
      value.addClass("selected-word");
    });
    var select_start = $cell.get_start_cell();
    select_start.corresponding_clue().addClass("selected-clue");
    cw.scroll_to_selected();
  },

  // Returns all letters of the puzzle in order, voids replaced by underscores
  get_puzzle_letters: function() {
    var letters = '';
    var $cells = $(".cell");
    $.each($cells, function(index, cell) {
      letters += ($(cell).hasClass("void") ? "_" : $(cell).get_letter());
    });
    return letters;
  },

  // Intelligently sets the numbers of each cell in the crossword
  number_cells: function() {
    cw.counter = 1;
    var $cells = $(".cell:not(.void)");
    $.each($cells, function(index, value) {
      cw.number_cell($(value));
    });
  },

  // Numbers cells that start a word (leftmost or topmost in a word)
  number_cell: function($cell) {
    if (!$cell.has_above() || !$cell.has_left()) {
      $cell.set_number(cw.counter);
      $cell.attr("data-cell", cw.counter);
      cw.counter += 1;
    } else if ($cell.get_number() !== " ") {
      $cell.set_number("");
      $cell.removeAttr("data-cell");
    }
  },

  // Handles all keypresses: arrow navigation, tab, enter, escape, delete, typing
  keypress: function(e) {
    if (!(e.ctrlKey || e.altKey || e.metaKey) && (cw.selected && ($(":focus").length === 0))) {
      var key = e.which;
      switch (key) {
        case cw.UP:
          if (cw.selected) {
            if (cw.selected.cell_above()) {
              cw.selected.cell_above().highlight();
            } else {
              var wraparound_cell = cw.selected.get_col_end();
              if (wraparound_cell.is_void()) wraparound_cell = wraparound_cell.cell_above();
              wraparound_cell.highlight();
            }
          }
          break;
        case cw.RIGHT:
          if (cw.selected) {
            if (cw.selected.cell_to_right()) {
              cw.selected.cell_to_right().highlight();
            } else {
              var wraparound_cell = cw.selected.get_row_beginning();
              if (wraparound_cell.is_void()) wraparound_cell = wraparound_cell.cell_to_right();
              wraparound_cell.highlight();
            }
          }
          break;
        case cw.DOWN:
          if (cw.selected) {
            if (cw.selected.cell_below()) {
              cw.selected.cell_below().highlight();
            } else {
              var wraparound_cell = cw.selected.get_col_beginning();
              if (wraparound_cell.is_void()) wraparound_cell = wraparound_cell.cell_below();
              wraparound_cell.highlight();
            }
          }
          break;
        case cw.LEFT:
          if (cw.selected) {
            if (cw.selected.cell_to_left()) {
              cw.selected.cell_to_left().highlight();
            } else {
              var wraparound_cell = cw.selected.get_row_end();
              if (wraparound_cell.is_void()) wraparound_cell = wraparound_cell.cell_to_left();
              wraparound_cell.highlight();
            }
          }
          break;
        case cw.TAB:
          e.preventDefault();
          cw.highlight_next_word();
          break;
        case cw.ESCAPE:
          e.preventDefault();
          cw.unhighlight_all();
          break;
        case cw.ENTER:
          e.preventDefault();
          cw.selected.next_empty_cell().highlight();
          break;
        case cw.SHIFT:
          break;
        case cw.DELETE:
          break;
        case cw.SPACE:
          cw.select_across = !cw.select_across;
          $(".selected").highlight();
          break;
        default:
          if (cw.selected) {
            var letter = String.fromCharCode(key);
            if (key === cw.HYPHEN) letter = '-';
            if (letter !== cw.selected.get_letter()) {
              if (cw.editing) {
                cw.selected.set_letter(letter, true);
                edit_app.update_unsaved();
              } else {
                var check_for_finish = cw.selected.is_empty_cell();
                cw.selected.set_letter(letter, true);
                if (check_for_finish) cw.selected.check_finisheds();
                solve_app.update_unsaved();
              }
            }
            if (!cw.selected.is_word_end()) {
              cw.selected.next_empty_cell_in_word().highlight();
            }
          }
      }
    }
  },

  highlight_clue_cell: function($clue) {
    var $cell = cw.editing ?
      $(".cell[data-id='" + $clue.data('cell-id') + "']").first() :
      $(".cell[data-cell='" + $clue.attr("data-cell-num") + "']").first();
    cw.select_across = $clue.closest(".clues").attr("id") === "across";
    $cell.highlight();
    if (cw.editing) $clue.children('input').select();
  },

  // Prevents backspace from navigating back, prevents arrow keys/space from scrolling page
  suppressBackspaceAndNav: function(evt) {
    evt = evt || window.event;
    var target = evt.target || evt.srcElement;
    if (evt.keyCode === cw.BACKSPACE && !/input|textarea/i.test(target.nodeName)) {
      var check_for_unfinish = !cw.selected.is_empty_cell();
      cw.selected.delete_letter(true);
      if (check_for_unfinish) cw.selected.uncheck_unfinisheds();
      return false;
    }
    if (cw.PAGE_NAV_KEYS.includes(evt.keyCode) && !/input|textarea/i.test(target.nodeName)) {
      return false;
    }
  }
};

cw.PAGE_NAV_KEYS = [cw.UP, cw.RIGHT, cw.DOWN, cw.LEFT, cw.SPACE];
document.onkeydown = cw.suppressBackspaceAndNav;
document.onkeypress = cw.suppressBackspaceAndNav;

// Use turbo:load instead of $(document).ready() so click handlers are
// re-bound after Turbo Drive replaces the page body on navigation.
// Remove+re-add to avoid duplicate listeners on repeated crossword visits
// (solve.js is loaded in <head> so it executes once per page-type change).
if (window._cwTurboLoadHandler) document.removeEventListener("turbo:load", window._cwTurboLoadHandler);
window._cwTurboLoadHandler = function() {
  if (!$(".cell").length) return; // not on a crossword page
  if (!cw.editing) cw.number_cells();
  $(document).off("keydown.cw").on("keydown.cw", cw.keypress);
  $(".cell").on("click", function(e) {
    e.stopPropagation();
    if ($('#unpublished_crossword_one_click_void').prop('checked')) {
      $(this).toggle_void(true);
    } else if ($('#unpublished_crossword_circle_mode').prop('checked')) {
      $(this).toggleCircle();
    } else {
      $(this).highlight();
    }
  });

  $(".clue").on("click", function(e) {
    e.stopPropagation();
    cw.highlight_clue_cell($(this));
  });

  cw.selected = $(".cell:not(.void)").first();
  if (cw.selected.length) cw.selected.highlight();
};
document.addEventListener("turbo:load", window._cwTurboLoadHandler);
