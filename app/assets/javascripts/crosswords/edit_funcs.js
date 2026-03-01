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
      success: function() { /* saved */ },
      error: function() {
        alert('Error updating letters!');
      }
    };
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
