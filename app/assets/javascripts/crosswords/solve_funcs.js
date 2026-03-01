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

// Use turbo:load instead of $(document).ready() so solve_app.ready() is
// called after Turbo Drive replaces the body. Remove+re-add to avoid
// duplicate listeners when solve.js (in <head>) re-executes on page type change.
if (window._solveTurboLoadHandler) document.removeEventListener("turbo:load", window._solveTurboLoadHandler);
window._solveTurboLoadHandler = function() {
  if (!$(".cell").length) return; // not on a crossword page
  solve_app.ready();
};
document.addEventListener("turbo:load", window._solveTurboLoadHandler);
