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
/*
Crossword Editing Functions
---------------------------
This file defines functions used only by the site's Javascript-based
crossword editor. Functions are scoped inside of the 'edit_app'
variable, with the exception of jQuery custom functions which may
be called by any jQuery object.
*/

cw.editing = true;

window.edit_app = {
  unsaved_changes: false,
  save_timer: null,
  last_save: null,
  SAVE_INTERVAL: 15000,
  title_spinner: null,
  save_counter: null,

  ready: function() {
    edit_app.save_timer = window.setInterval(function() {
      if (edit_app.unsaved_changes) edit_app.save_puzzle();
    }, edit_app.SAVE_INTERVAL);
    $('#title-status').show();

    $('#crossword').on('dblclick', '.cell', function() { $(this).toggle_void(true); });
    $('#edit-save').on('click', edit_app.save_puzzle);
    $('#title').on('change', edit_app.update_title);
    $('.clue').on('change', 'input', edit_app.update_clue);
    $('.clue').on('click', function() { $(".cell[data-index=" + $(this).data('index') + "]").highlight(); });
    $('#description').on('change', edit_app.update_description);

    $('.switch-form input').on('click', edit_app.flip_switch);
    $(':not(.cell, .cell *, .clue, .clue *)').on('click', function() { cw.unhighlight_all(); });

    $('#ideas input[name=word]').on('keypress', edit_app.add_potential_word);
    $('#settings-button').on('click', function() { $('#edit-settings').foundation('reveal', 'open'); });
    $('.bottom-button').on('click', function() { $(this).closest('.slide-up-container').toggleClass('open'); });
  },

  flip_switch: function(e) {
    $(this).parent().toggleClass('on off');
    $(this).closest('form').submit();
  },

  add_potential_word: function(e) {
    if (!e.metaKey) {
      var key = e.which;
      if (key === cw.ENTER) {
        e.preventDefault();
        if ($(this).val() !== '') {
          $(this).parent().submit();
        }
      }
    }
  },

  update_clue: function(e) {
    edit_app.update_unsaved();
  },

  update_title: function(e) {
    var title_status = $('#title-status');
    title_status.css('opacity', 1);

    var token = $('#crossword').data('auth-token');
    var id = $('#crossword').data('id');

    var settings = {
      dataType: 'script',
      type: 'PUT',
      url: "/unpublished_crosswords/" + id,
      data: {
        unpublished_crossword: { title: $('#title').val() },
        authenticity_token: token
      },
      success: function() {
        title_status.addClass('fi-check').removeClass('fi-x');
      },
      error: function() {
        title_status.addClass('fi-x').removeClass('fi-check');
      },
      complete: function() {
        title_status.fadeTo(1500, 0, function() {
          title_status.removeClass('fi-check fi-x');
        });
      }
    };
    $.ajax(settings);
  },

  update_description: function(e) {
    var token = $('#crossword').data('auth-token');
    var id = $('#crossword').data('id');

    var settings = {
      dataType: 'script',
      type: 'PUT',
      url: "/unpublished_crosswords/" + id,
      data: {
        unpublished_crossword: { description: $('#description').val() },
        authenticity_token: token
      },
      error: function() {
        alert('Error updating title!');
      }
    };
    $.ajax(settings);
  },

  update_unsaved: function() {
    edit_app.unsaved_changes = true;
    edit_app.save_counter = Math.random().toString();
    $('#save-status').text('Unsaved changes');
    $('#save-clock').empty();
  },

  spin_title: function() {
    $('.spinner').remove();
    var opts = {
      lines: 10,
      length: 7,
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
    };
    var target = document.getElementById('title-status');
    edit_app.title_spinner = new Spinner(opts).spin(target);
  },

  number_clues: function() {
    $('.clue').each(function() {
      var clue_num = $(this).children('.clue-num');
      var cell_index = $(this).data('index');
      var cell_num = parseInt($(".cell[data-index=" + cell_index + "]").first().attr('data-cell'));
      clue_num.text(cell_num + ".");
    });
  },

  save_puzzle: function(e) {
    var letters_array = [];
    var $cells = $('.cell');
    $.each($cells, function(i, cell) {
      if ($(cell).is_void()) {
        letters_array[i] = 0;
      } else {
        letters_array[i] = $(cell).get_letter();
      }
    });

    var across_clues = [];
    var down_clues = [];
    $.each($('.across-clue'), function() {
      across_clues.push($(this).children('input').val());
    });
    $.each($('.down-clue'), function() {
      down_clues.push($(this).children('input').val());
    });

    var token = $('#crossword').data('auth-token');
    var id = $('#crossword').data('id');
    var settings = {
      dataType: 'script',
      contentType: 'application/json',
      type: 'PATCH',
      url: "/unpublished_crosswords/" + id + "/update_letters",
      data: JSON.stringify({ letters: letters_array, circles: edit_app.circles, across_clues: across_clues, down_clues: down_clues, authenticity_token: token, save_counter: edit_app.save_counter }),
      success: function() {
        console.log('Saved!');
      },
      error: function() {
        alert('Error updating letters!');
      }
    };
    console.log('Saving...');
    $.ajax(settings);
  },

  log_save: function() {
    edit_app.last_save = moment().format("dddd, MMMM Do YYYY, h:mm:ss a");
    edit_app.unsaved_changes = false;
  },

  update_clock: function() {
    if (edit_app.last_save) {
      $('#save-status').text('Saved ');
      $('#save-clock').text(moment(edit_app.last_save).fromNow());
    }
  }
};

// jQuery editing functions
(function($) {
  $.fn.corresponding_clues = function() {
    return $(".clue[data-index=" + this.data("index") + "]");
  };

  $.fn.delete_letter = function(letter) {
    if (this.is_empty_cell()) {
      if (!this.is_word_start()) {
        if (!this.previous_cell().is_empty_cell()) {
          this.previous_cell().delete_letter(true);
        }
        this.previous_cell().highlight();
        return false;
      }
    } else {
      this.children(".letter").first().empty();
    }
  };

  $.fn.get_mirror_cell = function() {
    var $cells = $(".cell");
    var cell_count = $cells.length;
    var this_index = $.inArray(this[0], $cells);
    return $($cells[cell_count - this_index - 1]);
  };

  $.fn.toggleCircle = function() {
    var existing_circles = $(this).children('.circle');
    var index = $(this).data('index');
    var circles_a = edit_app.circles.split('');
    if (existing_circles.length > 0) {
      existing_circles.remove();
      circles_a[index] = ' ';
    } else {
      var circle = $('<div>').addClass('circle');
      $(this).append(circle);
      circles_a[index] = 'o';
    }
    edit_app.circles = circles_a.join('');
    edit_app.update_unsaved();
  };

  $.fn.toggle_void = function(recursive) {
    this.set_letter('');
    this.toggleClass('void');

    if (this.hasClass('void')) {
      this.corresponding_clues().hide();
      if (this.has_below()) this.cell_below().corresponding_clues().filter(".down-clue").show();
      if (this.has_right()) this.cell_to_right().corresponding_clues().filter(".across-clue").show();
    } else {
      if (this.has_below()) this.cell_below().corresponding_clues().filter(".down-clue").hide();
      if (this.has_right()) this.cell_to_right().corresponding_clues().filter(".across-clue").hide();
      if (!this.cell_above()) this.corresponding_clues().filter(".down-clue").show();
      if (!this.cell_to_left()) this.corresponding_clues().filter(".across-clue").show();
    }

    if (recursive && $('#unpublished_crossword_mirror_voids').prop('checked')) {
      var mirror_cell = this.get_mirror_cell();
      if (this[0] !== mirror_cell[0] && this.hasClass('void') !== mirror_cell.hasClass('void')) {
        mirror_cell.toggle_void(false);
      }
    }

    if (recursive) {
      var next_cell = cw.select_across ? this.cell_to_right() : this.cell_below();
      next_cell.highlight();
    }
    cw.number_cells();
    edit_app.number_clues();
    edit_app.update_unsaved();
  };
})(jQuery);

// Use turbo:load instead of $(document).ready() so edit_app.ready() is
// called after Turbo Drive replaces the body. Remove+re-add to avoid
// duplicate listeners when edit.js (in <head>) re-executes on page type change.
if (window._editTurboLoadHandler) document.removeEventListener("turbo:load", window._editTurboLoadHandler);
window._editTurboLoadHandler = function() {
  if (!$(".cell").length) return; // not on a crossword page
  edit_app.ready();
};
document.addEventListener("turbo:load", window._editTurboLoadHandler);
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


