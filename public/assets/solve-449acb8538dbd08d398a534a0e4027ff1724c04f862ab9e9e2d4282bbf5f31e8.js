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
    if (_.contains(cw.PAGE_NAV_KEYS, evt.keyCode) && !/input|textarea/i.test(target.nodeName)) {
      return false;
    }
  }
};

cw.PAGE_NAV_KEYS = [cw.UP, cw.RIGHT, cw.DOWN, cw.LEFT, cw.SPACE];
document.onkeydown = cw.suppressBackspaceAndNav;
document.onkeypress = cw.suppressBackspaceAndNav;

$(function() {
  if (!cw.editing) cw.number_cells();
  $(document).on("keydown", cw.keypress);
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
  cw.selected.highlight();
});
/*
Crossword Solving Functions
---------------------------
This file defines functions used only by the site's Javascript-based
crossword solver. Functions are scoped inside of the 'solve_app'
variable, with the exception of jQuery custom functions which may
be called by any jQuery object.
*/

window.solve_app = {
  logged_in: null,
  crossword_id: null,
  solution_id: null,
  save_timer: null,
  clock_updater: null,
  last_save: null,
  unsaved_changes: false,

  ready: function() {
    if (!solve_app.anonymous) {
      solve_app.save_timer = window.setInterval(function() {
        if (solve_app.unsaved_changes) solve_app.save_solution();
      }, 5000);
      solve_app.clock_updater = window.setInterval(solve_app.update_clock, 10000);
      $('#comments').on('keypress', '.reply-content', solve_app.add_comment_or_reply);
      $('#comments').on('click', '.reply-button.reply', solve_app.toggle_reply_form);
      $('#solve-save').on('click', solve_app.save_solution);
      $('#add-comment').on('keypress', solve_app.add_comment_or_reply);
      $('.cancel-button').on('click', solve_app.toggle_reply_form);
    }
    $('#controls-button').on('click', function(e) {
      e.preventDefault();
      $('#controls-modal').foundation('reveal', 'open');
    });
    $('#check-cell').on('click', solve_app.check_cell);
    $('#check-word').on('click', solve_app.check_word);
    $('#check-puzzle').on('click', solve_app.check_puzzle);
    $("#solve-controls").on('click', '.check-completion :not(span)', solve_app.check_completion);
    $('input, textarea').on('click', function() { cw.unhighlight_all(); });
    solve_app.check_all_finished();
    return true;
  },

  save_solution: function(e) {
    if (e) e.preventDefault();
    var token = $('#crossword').data('auth-token');
    var letters = cw.get_puzzle_letters();
    var settings = {
      dataType: 'script',
      type: 'PUT',
      url: "/solutions/" + solve_app.solution_id,
      data: { authenticity_token: token, letters: letters }
    };
    $.ajax(settings);
  },

  log_save: function() {
    solve_app.last_save = moment().format("dddd, MMMM Do YYYY, h:mm:ss a");
    solve_app.unsaved_changes = false;
  },

  update_clock: function() {
    if (solve_app.last_save && !solve_app.anonymous) {
      $('#save-status').text('Saved ');
      $('#save-clock').text(moment(solve_app.last_save).fromNow());
    }
  },

  update_unsaved: function() {
    if (!solve_app.anonymous) {
      solve_app.unsaved_changes = true;
      $('#save-status').text('Unsaved changes');
      $('#save-clock').empty();
    }
  },

  check_cell: function(e) {
    e.preventDefault();
    if (cw.selected) {
      if (cw.selected.is_empty_cell()) {
        alert('This cell is empty.');
      } else {
        var index = cw.selected.data('index');
        var letter = cw.selected.get_letter();
        var settings = {
          dataType: 'script',
          type: 'POST',
          url: "/crosswords/" + solve_app.crossword_id + "/check_cell",
          data: { letters: [letter], indices: [] }
        };
        settings.data.indices.push(index);
        $.ajax(settings);
        solve_app.save_solution();
      }
    }
  },

  check_word: function(e) {
    e.preventDefault();
    if (cw.selected) {
      var settings = {
        dataType: 'script',
        type: 'POST',
        url: "/crosswords/" + solve_app.crossword_id + "/check_cell",
        data: { letters: [], indices: [] }
      };
      var word_cells = cw.selected.get_word_cells();
      for (var i = 0; i < word_cells.length; i++) {
        var cell = word_cells[i];
        if (!cell.is_empty_cell()) {
          settings.data.indices.push(cell.data('index'));
          settings.data.letters.push(cell.get_letter());
        }
      }
      if (settings.data.letters.length === 0) {
        alert('The selected word is empty.');
      } else {
        $.ajax(settings);
        solve_app.save_solution();
      }
    }
  },

  check_puzzle: function(e) {
    e.preventDefault();
    solve_app.save_solution();
    var settings = {
      dataType: 'script',
      type: 'POST',
      url: "/crosswords/" + solve_app.crossword_id + "/check_cell",
      data: { letters: cw.get_puzzle_letters() }
    };
    $.ajax(settings);
    solve_app.save_solution();
  },

  check_completion: function(e) {
    e.preventDefault();
    solve_app.save_solution();
    var letters = cw.get_puzzle_letters();
    var settings = {
      dataType: 'script',
      type: 'POST',
      url: "/crosswords/" + solve_app.crossword_id + "/check_completion",
      data: { letters: letters }
    };
    if (!solve_app.anonymous) {
      settings.data['solution_id'] = solve_app.solution_id;
    }
    $.ajax(settings);
  },

  add_comment_or_reply: function(e) {
    if (!e.metaKey) {
      var key = e.which;
      if (key === cw.ENTER) {
        e.preventDefault();
        if ($(this).val() !== '') {
          $('.replying').removeClass('replying');
          $(this).closest('.comment').addClass('replying');
          $(this).parent().submit();
          $(this).val('');
        }
      }
    }
  },

  toggle_reply_form: function(e) {
    if (e) e.preventDefault();
    var reply_form = $(this).siblings('form');
    reply_form.toggle('fast');
    $(this).siblings('a').toggle();
    $(this).toggle();
    var is_showing = (reply_form.css('opacity') < 0.5);
    if (is_showing) {
      reply_form.children('textarea').focus();
    } else {
      reply_form[0].reset();
    }
  },

  check_all_finished: function() {
    $.each($('.cell:not(.void)'), function(index, cell) {
      if (!$(cell).has_left()) {
        if ($(cell).in_finished_across_word()) $(cell).corresponding_across_clue().addClass('crossed-off');
      }
      if (!$(cell).has_above()) {
        if ($(cell).in_finished_down_word()) $(cell).corresponding_down_clue().addClass('crossed-off');
      }
    });
  }
};

// jQuery solving functions
(function($) {
  $.fn.delete_letter = function(original) {
    if (this.is_empty_cell()) {
      if (!this.is_word_start()) {
        if (!this.previous_cell().is_empty_cell()) {
          this.previous_cell().delete_letter(true);
          solve_app.update_unsaved();
        }
        this.previous_cell().highlight();
        return false;
      }
    } else {
      this.children(".letter").first().empty();
      if (typeof team_app !== 'undefined') {
        if (original) {
          team_app.send_team_cell(this, "");
        } else {
          this.uncheck_unfinisheds();
        }
      }
      solve_app.update_unsaved();
    }
  };
})(jQuery);

$(document).ready(solve_app.ready);
/*
Custom jQuery Functions for Cells
-----------------------
These functions are used by both the in-site crossword solver and editor. While they can
technically be called by any jQuery object, they are intended to be called by the td.cell
elements of the table#crossword
*/

(function($) {
  $.fn.get_row = function() {
    return this.data("row");
  };
  $.fn.get_col = function() {
    return this.data("col");
  };

  $.fn.is_void = function() {
    return this.hasClass("void");
  };

  $.fn.in_top_row = function() {
    return $(this).get_row() === 1;
  };
  $.fn.in_bottom_row = function() {
    return this.get_row() === $("#crossword").data("rows");
  };
  $.fn.in_left_col = function() {
    return this.get_col() === 1;
  };
  $.fn.in_right_col = function() {
    return this.get_col() === $("#crossword").data("cols");
  };

  $.fn.get_row_beginning = function() {
    var row = parseInt(this.get_row());
    return $(".cell[data-row=" + row + "][data-col=1]");
  };
  $.fn.get_row_end = function() {
    var row = parseInt(this.get_row());
    return $(".cell[data-row=" + row + "][data-col=" + $("#crossword").data("cols") + "]");
  };
  $.fn.get_col_beginning = function() {
    var col = parseInt(this.get_col());
    return $(".cell[data-row=1][data-col=" + col + "]");
  };
  $.fn.get_col_end = function() {
    var col = parseInt(this.get_col());
    return $(".cell[data-row=" + $("#crossword").data("rows") + "][data-col=" + col + "]");
  };

  // Return booleans indicating whether there is a cell adjacent to the one calling
  // the function and whether it is non-void
  $.fn.has_above = function() {
    if (this.in_top_row()) {
      return false;
    } else {
      var row = parseInt(this.get_row());
      var col = parseInt(this.get_col());
      var above = $(".cell[data-row='" + (row - 1) + "'][data-col='" + col + "']");
      return !above.is_void();
    }
  };
  $.fn.has_below = function() {
    if (this.in_bottom_row()) {
      return false;
    } else {
      var row = parseInt(this.get_row());
      var col = parseInt(this.get_col());
      var below = $(".cell[data-row='" + (row + 1) + "'][data-col='" + col + "']");
      return !below.is_void();
    }
  };
  $.fn.has_left = function() {
    if (this.in_left_col()) {
      return false;
    } else {
      var row = parseInt(this.get_row());
      var col = parseInt(this.get_col());
      var left = $(".cell[data-row='" + row + "'][data-col='" + (col - 1) + "']");
      return !left.is_void();
    }
  };
  $.fn.has_right = function() {
    if (this.in_right_col()) {
      return false;
    } else {
      var row = parseInt(this.get_row());
      var col = parseInt(this.get_col());
      var right = $(".cell[data-row='" + row + "'][data-col='" + (col + 1) + "']");
      return !right.is_void();
    }
  };

  // Returns the jQuery object of the adjacent cell
  $.fn.cell_to_left = function() {
    if (this.in_left_col()) {
      return false;
    } else {
      var left_cell = this.prevAll(".cell:not(.void)").first();
      return left_cell.get(0) ? left_cell : false;
    }
  };
  $.fn.cell_to_right = function() {
    if (this.in_right_col()) {
      return false;
    } else {
      var right_cell = this.nextAll(".cell:not(.void)").first();
      return right_cell.get(0) ? right_cell : false;
    }
  };
  $.fn.cell_above = function() {
    if (this.in_top_row()) {
      return false;
    } else {
      var row = parseInt(this.get_row());
      var col = parseInt(this.get_col());
      var above = $(".cell[data-row='" + (row - 1) + "'][data-col='" + col + "']");
      if (!above.is_void()) {
        return above;
      } else {
        return above.cell_above();
      }
    }
  };
  $.fn.cell_below = function() {
    if (this.in_bottom_row()) {
      return false;
    } else {
      var row = parseInt(this.get_row());
      var col = parseInt(this.get_col());
      var below = $(".cell[data-row='" + (row + 1) + "'][data-col='" + col + "']");
      if (!below.is_void()) {
        return below;
      } else {
        return below.cell_below();
      }
    }
  };

  $.fn.previous_cell = function() {
    return cw.select_across ? this.cell_to_left() : this.cell_above();
  };
  $.fn.next_cell = function() {
    return cw.select_across ? this.cell_to_right() : this.cell_below();
  };

  $.fn.is_word_start = function() {
    return !(cw.select_across ? this.has_left() : this.has_above());
  };
  $.fn.is_word_end = function() {
    return !(cw.select_across ? this.has_right() : this.has_below());
  };

  $.fn.get_down_word_cells = function() {
    return this.get_down_start_cell().down_word_from_start();
  };
  $.fn.get_down_start_cell = function() {
    if (!this.has_above()) {
      return this;
    } else {
      return this.cell_above().get_down_start_cell();
    }
  };
  $.fn.get_down_end_cell = function() {
    if (!this.has_below()) {
      return this;
    } else {
      return this.cell_below().get_down_end_cell();
    }
  };
  $.fn.down_word_from_start = function() {
    if (!this.has_below()) {
      return [this];
    } else {
      return [this].concat(this.cell_below().down_word_from_start());
    }
  };
  $.fn.get_down_word = function() {
    return $.map(this.get_down_word_cells(), function(el, i) {
      return el.text();
    }).join("");
  };

  $.fn.get_across_word_cells = function() {
    return this.get_across_start_cell().across_word_from_start();
  };
  $.fn.get_across_start_cell = function() {
    if (!this.has_left()) {
      return this;
    } else {
      return this.cell_to_left().get_across_start_cell();
    }
  };
  $.fn.get_across_end_cell = function() {
    if (!this.has_right()) {
      return this;
    } else {
      return this.cell_to_right().get_across_end_cell();
    }
  };
  $.fn.across_word_from_start = function() {
    if (!this.has_right()) {
      return [this];
    } else {
      return [this].concat(this.cell_to_right().across_word_from_start());
    }
  };
  $.fn.get_across_word = function() {
    return $.map(this.get_across_word_cells(), function(el, i) {
      return el.text();
    }).join("");
  };

  $.fn.get_word_cells = function() {
    return cw.select_across ? this.get_across_word_cells() : this.get_down_word_cells();
  };

  $.fn.word_from_start = function() {
    return cw.select_across ? this.across_word_from_start() : this.down_word_from_start();
  };

  $.fn.get_start_cell = function() {
    return cw.select_across ? this.get_across_start_cell() : this.get_down_start_cell();
  };

  $.fn.get_end_cell = function() {
    return cw.select_across ? this.get_across_end_cell() : this.get_down_end_cell();
  };

  // Both a td.cell's number (if any) and its letter are stored as child divs
  $.fn.get_number = function() {
    var letter = this.children(".cell-num").text();
    return (letter.length > 0 ? letter : " ");
  };

  $.fn.set_number = function(number) {
    this.children(".cell-num").text(number);
  };

  $.fn.get_letter = function() {
    var letter = this.children(".letter").first().text().replace(/\n/g, "").replace(RegExp("  +", "g"), "");
    return (letter.length > 0 ? letter : " ");
  };

  $.fn.set_letter = function(letter, original) {
    this.children(".letter").first().text(letter);
    if (typeof team_app !== 'undefined') {
      if (original) {
        team_app.send_team_cell(this, letter);
      } else {
        this.check_finisheds();
      }
    }
  };

  $.fn.is_last_letter_of_puzzle = function() {
    var word_cells = cw.select_across ? this.get_across_word_cells() : this.get_down_word_cells();
    var last_index = word_cells.length - 1;
    return this[0] === word_cells[last_index][0];
  };

  $.fn.is_empty_cell = function() {
    return (this.get_letter() === "") || (this.get_letter() === " ") || (this.get_letter().replace(/\n/g, "").replace(RegExp("  +", "g"), " ") === " ");
  };

  $.fn.corresponding_across_clue = function() {
    return (this.data('cell') ? $(".across-clue[data-cell-num=" + this.data('cell') + "]") : $(".across-clue[data-index=" + this.data('index') + "]"));
  };

  $.fn.corresponding_down_clue = function() {
    return (this.data('cell') ? $(".down-clue[data-cell-num=" + this.data('cell') + "]") : $(".down-clue[data-index=" + this.data('index') + "]"));
  };

  $.fn.corresponding_clue = function() {
    return cw.select_across ? this.corresponding_across_clue() : this.corresponding_down_clue();
  };

  // Highlights this cell as the current cell, unhighlights all others, and highlights the word
  $.fn.highlight = function() {
    if (this.hasClass("cell") && !this.is_void()) {
      cw.unhighlight_all();
      cw.selected = this;
      this.addClass("selected");
      cw.word_highlight();
    }
  };

  $.fn.in_finished_across_word = function() {
    var cells = this.get_across_word_cells();
    var is_finished = true;
    for (var i = 0; i < cells.length; i++) {
      if (cells[i].is_empty_cell()) {
        is_finished = false;
        break;
      }
    }
    return is_finished;
  };

  $.fn.in_finished_down_word = function() {
    var cells = this.get_down_word_cells();
    var is_finished = true;
    for (var i = 0; i < cells.length; i++) {
      if (cells[i].is_empty_cell()) {
        is_finished = false;
        break;
      }
    }
    return is_finished;
  };

  $.fn.in_finished_word = function() {
    var cells = this.get_word_cells();
    var is_finished = true;
    for (var i = 0; i < cells.length; i++) {
      if (cells[i].is_empty_cell()) {
        is_finished = false;
        break;
      }
    }
    return is_finished;
  };

  $.fn.in_directional_finished_word = function() {
    return cw.select_across ? this.in_finished_across_word() : this.in_finished_down_word();
  };

  $.fn.check_finisheds = function() {
    if (this.in_finished_across_word()) {
      this.get_across_start_cell().corresponding_across_clue().addClass("crossed-off");
    }
    if (this.in_finished_down_word()) {
      this.get_down_start_cell().corresponding_down_clue().addClass("crossed-off");
    }
  };

  $.fn.uncheck_unfinisheds = function() {
    this.get_across_start_cell().corresponding_across_clue().removeClass("crossed-off");
    this.get_down_start_cell().corresponding_down_clue().removeClass("crossed-off");
  };

  $.fn.next_empty_cell_in_word = function() {
    return (this.is_word_end() || this.is_empty_cell()) ? this : this.next_cell().next_empty_cell_in_word();
  };

  $.fn.next_empty_cell = function() {
    if (this.is_last_letter_of_puzzle()) {
      if (this.is_empty_cell()) {
        return this;
      } else {
        cw.highlight_next_word();
        if ($(".selected").get_number() !== 1) {
          return $(".selected").is_empty_cell() ? $(".selected") : $(".selected").next_empty_cell();
        }
      }
    } else {
      var next = this.next_cell();
      return next.is_empty_cell() ? next : next.next_empty_cell();
    }
  };

})(jQuery);


