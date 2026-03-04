// Crossword solver: auto-save, check cell/word/puzzle, comment entry.

window.solve_app = {
  logged_in: null,
  crossword_id: null,
  solution_id: null,
  save_timer: null,
  clock_updater: null,
  last_save: null,
  unsaved_changes: false,
  save_counter: null,

  ready: function() {
    // Clear any stale beforeunload handler from a previous anonymous session
    window.onbeforeunload = null;
    if (!solve_app.anonymous && solve_app.solution_id) {
      // Clear any previous timers to prevent phantom saves after Turbo navigation
      if (solve_app.save_timer) clearInterval(solve_app.save_timer);
      if (solve_app.clock_updater) clearInterval(solve_app.clock_updater);
      solve_app.save_timer = window.setInterval(function() {
        if (solve_app.unsaved_changes) solve_app.save_solution();
      }, 5000);
      solve_app.clock_updater = window.setInterval(solve_app.update_clock, 10000);
      $('#comments').on('keypress', '.reply-content', solve_app.add_comment_or_reply);
      $('#comments').on('click', '.reply-button.reply', solve_app.toggle_reply_form);
      $('#comments').on('click', '.reply-form__close', solve_app.toggle_reply_form);
      $('#comments').on('keydown', '.reply-content', function(e) {
        if (e.key === 'Escape') solve_app.toggle_reply_form.call(this, e);
      });
      $('#solve-save').on('click', solve_app.save_solution);
      $('#add-comment').on('keypress', solve_app.add_comment_or_reply);
    }
    $('#controls-button').on('click', function(e) {
      e.preventDefault();
      document.getElementById('controls-modal').showModal();
    });
    $('#comments').on('click', '.xw-comment__reply-count', function() {
      $(this).next('.replies').slideToggle('fast');
      $(this).toggleClass('xw-comment__reply-count--expanded');
      $(this).blur(); // prevent focus from keeping action overlay visible
    });
    // YouTube-style description truncation: hide "more" if content fits in 2 lines
    var desc = document.querySelector('.xw-byline__desc');
    var moreBtn = document.querySelector('.xw-byline__more');
    if (desc && moreBtn) {
      if (desc.scrollHeight <= desc.clientHeight) {
        desc.classList.add('xw-byline__desc--fits');
        moreBtn.style.display = 'none';
      }
      moreBtn.addEventListener('click', function() {
        desc.classList.toggle('xw-byline__desc--expanded');
        moreBtn.textContent = desc.classList.contains('xw-byline__desc--expanded') ? 'less' : 'more';
      });
    }
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
    // Guard: solution_id is null for anonymous users or when solution hasn't been created yet.
    // Without this, the auto-save timer would send PUT /solutions/null, which triggers a
    // server-side flash error ("Solution could not be found") that persists across pages.
    if (!solve_app.solution_id) return;
    var letters = cw.get_puzzle_letters();
    var counter = solve_app.save_counter;
    $.ajax({
      dataType: 'json',
      type: 'PUT',
      url: "/solutions/" + solve_app.solution_id,
      data: { letters: letters, save_counter: counter },
      success: function(data) {
        if (solve_app.save_counter == data.save_counter) {
          try {
            solve_app.log_save();
            solve_app.update_clock();
          } catch (err) {
            // Still clear the unsaved flag so auto-save doesn't loop forever
            solve_app.unsaved_changes = false;
            console.warn('save succeeded but UI update failed:', err);
          }
        }
      },
      error: function(xhr) {
        $('#save-status').text('Save failed');
        $('#save-clock').empty();
        console.warn('save_solution failed:', xhr.status, xhr.statusText);
      }
    });
  },

  log_save: function() {
    solve_app.last_save = new Date();
    solve_app.unsaved_changes = false;
  },

  update_clock: function() {
    if (solve_app.last_save && !solve_app.anonymous) {
      $('#save-status').text('Saved ');
      $('#save-clock').text(cw.timeAgo(solve_app.last_save));
    }
  },

  update_unsaved: function() {
    if (!solve_app.anonymous) {
      solve_app.unsaved_changes = true;
      solve_app.save_counter = Math.random().toString();
      $('#save-status').text('Unsaved changes');
      $('#save-clock').empty();
    } else {
      // Warn anonymous users they'll lose work if they navigate away
      window.onbeforeunload = function() { return true; };
    }
  },

  // Shared handler for check_cell/check_word/check_puzzle JSON responses.
  // Marks cells as correct/incorrect with a staggered golden flash cascade
  // that sweeps L→R, T→B (reading order), then fades to reveal error flags.
  apply_mismatches: function(data) {
    var mismatches = data.mismatches;
    var keys = Object.keys(mismatches).map(Number);

    // Sort by index — already reading order (HAML iterates rows then cols)
    keys.sort(function(a, b) { return a - b; });

    var count = keys.length;

    // Adaptive stagger: deliberate for words, rapid sweep for full puzzles
    var stagger;
    if (count <= 1)       stagger = 0;
    else if (count <= 20) stagger = 30;
    else                  stagger = Math.max(4, Math.round(1200 / (count - 1)));

    var reducedMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;

    keys.forEach(function(cellIndex, i) {
      var v = mismatches[cellIndex];
      var delay = reducedMotion ? 0 : stagger * i;

      setTimeout(function() {
        var cell = $($('.cell')[cellIndex]);

        // 1. Apply correct/incorrect state (flag renders under the flash)
        if (v) {
          cell.addClass('flagged incorrect').removeClass('correct');
        } else {
          if (cell.hasClass('incorrect')) {
            cell.addClass('flagged correct').removeClass('incorrect');
          }
        }

        // 2. Trigger golden flash overlay — fades to reveal flag state
        if (!reducedMotion) {
          cell.removeClass('cell-flash');
          cell[0].offsetWidth;  // Force reflow to restart animation on re-check
          cell.addClass('cell-flash');
        }
      }, delay);
    });

    // Cleanup flash classes after all animations complete
    if (!reducedMotion && count > 0) {
      var cleanup = (stagger * (count - 1)) + 400;
      setTimeout(function() {
        $('.cell-flash').removeClass('cell-flash');
      }, cleanup);
    }
  },

  check_cell: function(e) {
    e.preventDefault();
    if (cw.selected) {
      if (cw.selected.is_empty_cell()) {
        cw.flash('This cell is empty.', 'info');
      } else {
        var index = cw.selected.data('index');
        var letter = cw.selected.get_letter();
        $.ajax({
          dataType: 'json',
          type: 'POST',
          url: "/crosswords/" + solve_app.crossword_id + "/check_cell",
          data: { letters: [letter], indices: [index] },
          success: solve_app.apply_mismatches,
          error: function(xhr) { console.warn('check_cell failed:', xhr.status); }
        });
        solve_app.save_solution();
      }
    }
  },

  check_word: function(e) {
    e.preventDefault();
    if (cw.selected) {
      var letters = [];
      var indices = [];
      var word_cells = cw.selected.get_word_cells();
      for (var i = 0; i < word_cells.length; i++) {
        var cell = word_cells[i];
        if (!cell.is_empty_cell()) {
          indices.push(cell.data('index'));
          letters.push(cell.get_letter());
        }
      }
      if (letters.length === 0) {
        cw.flash('The selected word is empty.', 'info');
      } else {
        $.ajax({
          dataType: 'json',
          type: 'POST',
          url: "/crosswords/" + solve_app.crossword_id + "/check_cell",
          data: { letters: letters, indices: indices },
          success: solve_app.apply_mismatches,
          error: function(xhr) { console.warn('check_word failed:', xhr.status); }
        });
        solve_app.save_solution();
      }
    }
  },

  check_puzzle: function(e) {
    e.preventDefault();
    solve_app.save_solution();
    $.ajax({
      dataType: 'json',
      type: 'POST',
      url: "/crosswords/" + solve_app.crossword_id + "/check_cell",
      data: { letters: cw.get_puzzle_letters() },
      success: solve_app.apply_mismatches,
      error: function(xhr) { console.warn('check_puzzle failed:', xhr.status); }
    });
  },

  check_completion: function(e) {
    e.preventDefault();
    solve_app.save_solution();
    var letters = cw.get_puzzle_letters();
    var data = { letters: letters };
    if (!solve_app.anonymous) {
      data['solution_id'] = solve_app.solution_id;
    }
    $.ajax({
      dataType: 'json',
      type: 'POST',
      url: "/crosswords/" + solve_app.crossword_id + "/check_completion",
      data: data,
      success: function(data) {
        if (data.correct) {
          var win_modal = $('#win-modal');
          if (!win_modal.attr('filled')) {
            win_modal.prepend(data.win_modal_html);
            win_modal.attr('filled', true);
          }
          document.getElementById('win-modal').showModal();
        } else {
          cw.flash('Your solution contains incorrect letters.', 'warning');
        }
      },
      error: function(xhr) { console.warn('check_completion failed:', xhr.status); }
    });
  },

  add_comment_or_reply: function(e) {
    if (!e.metaKey) {
      var key = e.which;
      if (key === cw.ENTER) {
        e.preventDefault();
        if ($(this).val() !== '') {
          var form = $(this).closest('form');
          form[0].requestSubmit();
          $(this).val('');
          // Close the reply form and expand replies so the new reply is visible
          if ($(this).hasClass('reply-content')) {
            var comment = $(this).closest('.xw-comment');
            comment.removeClass('xw-comment--replying');
            form.hide('fast');
            form[0].reset();
            var replies = comment.find('.replies');
            var countBtn = comment.find('.xw-comment__reply-count');
            if (replies.is(':hidden')) {
              replies.slideDown('fast');
              countBtn.addClass('xw-comment__reply-count--expanded');
            }
          }
        }
      }
    }
  },

  toggle_reply_form: function(e) {
    if (e) e.preventDefault();
    var comment = $(this).closest('.xw-comment');
    var reply_form = comment.find('.reply-form');
    var opening = reply_form.is(':hidden');
    comment.toggleClass('xw-comment--replying', opening);
    reply_form.toggle('fast');
    if (opening) {
      reply_form.find('textarea').focus();
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
