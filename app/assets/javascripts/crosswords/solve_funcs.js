// Crossword solver: auto-save, check cell/word/puzzle, comment entry.

window.solve_app = {
  logged_in: null,
  crossword_id: null,
  solution_id: null,
  save_timer: null,
  clock_updater: null,
  solve_timer_interval: null,
  started_at: null,
  is_complete: false,
  last_save: null,
  unsaved_changes: false,
  save_counter: null,

  // --- Solve timer ---

  start_solve_timer: function() {
    if (solve_app.solve_timer_interval) clearInterval(solve_app.solve_timer_interval);
    solve_app.update_solve_timer();
    if (!solve_app.is_complete) {
      solve_app.solve_timer_interval = setInterval(solve_app.update_solve_timer, 1000);
    }
  },

  stop_solve_timer: function() {
    if (solve_app.solve_timer_interval) {
      clearInterval(solve_app.solve_timer_interval);
      solve_app.solve_timer_interval = null;
    }
  },

  update_solve_timer: function() {
    var el = document.getElementById('solve-timer');
    if (!el || !solve_app.started_at) return;
    var elapsed = Math.floor((Date.now() - solve_app.started_at) / 1000);
    if (elapsed < 0) elapsed = 0;
    el.textContent = solve_app.format_elapsed(elapsed);
  },

  format_elapsed: function(total_seconds) {
    var days    = Math.floor(total_seconds / 86400);
    var hours   = Math.floor((total_seconds % 86400) / 3600);
    var minutes = Math.floor((total_seconds % 3600) / 60);
    var seconds = total_seconds % 60;

    var pad = function(n) { return n < 10 ? '0' + n : '' + n; };

    if (days > 0) {
      return days + 'd ' + pad(hours) + ':' + pad(minutes) + ':' + pad(seconds);
    } else if (hours > 0) {
      return hours + ':' + pad(minutes) + ':' + pad(seconds);
    } else {
      return pad(minutes) + ':' + pad(seconds);
    }
  },

  ready: function() {
    // Clear any stale beforeunload handler from a previous anonymous session
    window.onbeforeunload = null;
    // Start solve timer (works for both anonymous and logged-in)
    solve_app.start_solve_timer();
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
    $('#admin-fake-win').on('click', solve_app.fake_win);
    $('#admin-reveal-puzzle').on('click', solve_app.reveal_puzzle);
    $('#admin-clear-puzzle').on('click', solve_app.clear_puzzle);
    $('#admin-flash-cascade').on('click', solve_app.flash_cascade);
    $('#reveal-letter').on('click', solve_app.reveal_cell);
    $('#hint-word').on('click', solve_app.hint_word);
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

        // Revealed cells keep their black tab — never overwrite with check flags
        if (cell.hasClass('revealed')) return;

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
          solve_app.is_complete = true;
          solve_app.stop_solve_timer();
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

  // Admin-only: trigger win modal without completing the puzzle.
  // Bypasses letter comparison on the server. Re-triggerable (clears previous content).
  fake_win: function(e) {
    e.preventDefault();
    var data = {};
    if (!solve_app.anonymous) {
      data['solution_id'] = solve_app.solution_id;
    }
    $.ajax({
      dataType: 'json',
      type: 'POST',
      url: "/crosswords/" + solve_app.crossword_id + "/admin_fake_win",
      data: data,
      success: function(data) {
        if (data.correct) {
          var win_modal = $('#win-modal');
          // Clear previous content for re-trigger (keep close button)
          win_modal.children().not('.xw-modal__close').remove();
          win_modal.prepend(data.win_modal_html);
          win_modal.attr('filled', true);
          document.getElementById('win-modal').showModal();
        }
      },
      error: function(xhr) {
        if (xhr.status === 403) {
          cw.flash('Admin access required.', 'error');
        } else {
          cw.flash('Fake win failed.', 'error');
          console.warn('admin_fake_win failed:', xhr.status);
        }
      }
    });
  },

  // Admin-only: fill all cells with correct letters.
  // Sets letter text directly (not via set_letter) to avoid 225 individual
  // team broadcasts and per-cell check_finisheds calls. Batches the
  // crossing-off into a single check_all_finished() call at the end.
  reveal_puzzle: function(e) {
    e.preventDefault();
    $.ajax({
      dataType: 'json',
      type: 'POST',
      url: "/crosswords/" + solve_app.crossword_id + "/admin_reveal_puzzle",
      success: function(data) {
        var letters = data.letters;
        var $cells = $('.cell');
        $cells.each(function(index) {
          var $cell = $(this);
          if (!$cell.hasClass('void')) {
            $cell.children('.letter').first().text(letters[index]);
          }
        });
        // Clear any check flags from previous checks
        $cells.removeClass('flagged incorrect correct cell-flash');
        // Cross off all clues (all words are now complete)
        solve_app.check_all_finished();
        // Mark as unsaved — auto-save will fire within 5s
        solve_app.update_unsaved();
        cw.flash('Puzzle revealed!', 'success');
      },
      error: function(xhr) {
        if (xhr.status === 403) {
          cw.flash('Admin access required.', 'error');
        } else {
          cw.flash('Reveal failed.', 'error');
          console.warn('admin_reveal_puzzle failed:', xhr.status);
        }
      }
    });
  },

  // Admin-only: clear all letters and reset visual state.
  // Pure client-side — no server endpoint needed.
  clear_puzzle: function(e) {
    e.preventDefault();
    // Clear all letters from non-void cells
    $('.cell:not(.void)').each(function() {
      $(this).children('.letter').first().empty();
    });
    // Clear check flags from all cells
    $('.cell').removeClass('flagged incorrect correct cell-flash');
    // Un-cross-off all clues
    $('.crossed-off').removeClass('crossed-off');
    // Mark as unsaved — auto-save will fire within 5s
    solve_app.update_unsaved();
    cw.flash('Puzzle cleared.', 'info');
  },

  // Admin-only: trigger golden flash cascade across all non-void cells.
  // Pure client-side — reuses apply_mismatches with synthetic data.
  // All values set to false (correct) so no flag classes are applied —
  // only the golden flash animation sweeps the grid.
  flash_cascade: function(e) {
    e.preventDefault();
    var mismatches = {};
    $('.cell').each(function(index) {
      if (!$(this).hasClass('void')) {
        mismatches[index] = false;
      }
    });
    solve_app.apply_mismatches({ mismatches: mismatches });
  },

  // Reveal the correct letter for the selected cell.
  // Server returns only the requested letter — never the full answer key.
  reveal_cell: function(e) {
    e.preventDefault();
    if (!cw.selected) {
      cw.flash('Select a cell first.', 'info');
      return;
    }
    if (cw.selected.hasClass('void')) return;

    var index = cw.selected.data('index');
    var data = { indices: [index] };
    if (solve_app.solution_id) data.solution_id = solve_app.solution_id;

    $.ajax({
      dataType: 'json',
      type: 'POST',
      url: "/crosswords/" + solve_app.crossword_id + "/reveal",
      data: data,
      success: function(resp) {
        solve_app.apply_reveal(resp.letters);
      },
      error: function(xhr) {
        cw.flash('Reveal failed.', 'error');
        console.warn('reveal_cell failed:', xhr.status);
      }
    });
  },

  // Hint: reveal one random empty cell from the selected word.
  // Prefers unfilled cells; falls back to non-revealed cells with letters.
  hint_word: function(e) {
    e.preventDefault();
    if (!cw.selected) {
      cw.flash('Select a cell first.', 'info');
      return;
    }

    var word_cells = cw.selected.get_word_cells();

    // Prefer empty, non-revealed cells
    var candidates = word_cells.filter(function(_, el) {
      var $c = $(el);
      return !$c.hasClass('revealed') && $c.is_empty_cell();
    });
    // Fallback: non-revealed cells (may have wrong letters)
    if (candidates.length === 0) {
      candidates = word_cells.filter(function(_, el) {
        return !$(el).hasClass('revealed');
      });
    }
    if (candidates.length === 0) {
      cw.flash('Word already fully revealed.', 'info');
      return;
    }

    var pick = candidates.eq(Math.floor(Math.random() * candidates.length));
    var index = pick.data('index');

    var data = { indices: [index] };
    if (solve_app.solution_id) data.solution_id = solve_app.solution_id;

    $.ajax({
      dataType: 'json',
      type: 'POST',
      url: "/crosswords/" + solve_app.crossword_id + "/reveal",
      data: data,
      success: function(resp) {
        solve_app.apply_reveal(resp.letters);
      },
      error: function(xhr) {
        cw.flash('Hint failed.', 'error');
        console.warn('hint_word failed:', xhr.status);
      }
    });
  },

  // Apply revealed letters to cells. Sets each cell via set_letter (broadcasts
  // to team) and marks as correct. Triggers auto-save via update_unsaved.
  apply_reveal: function(letters) {
    var indices = Object.keys(letters).map(Number);
    if (indices.length === 0) return;

    indices.forEach(function(idx) {
      var $cell = $($('.cell')[idx]);
      $cell.set_letter(letters[idx], true);  // original=true → broadcasts to team
      $cell.addClass('flagged revealed').removeClass('incorrect correct');
    });

    // Flash cascade on revealed cells (reuse existing animation)
    var reducedMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
    if (!reducedMotion) {
      indices.forEach(function(idx) {
        var $cell = $($('.cell')[idx]);
        $cell.removeClass('cell-flash');
        $cell[0].offsetWidth; // force reflow
        $cell.addClass('cell-flash');
      });
      setTimeout(function() {
        $('.cell-flash').removeClass('cell-flash');
      }, 400);
    }

    solve_app.check_all_finished(); // cross off completed words
    solve_app.update_unsaved();     // trigger auto-save
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
