// Replaces jquery_ujs CSRF setup (removed during Hotwire migration).
// Attaches the CSRF token from the meta tag to every non-GET jQuery AJAX
// request via the X-CSRF-Token header, which Rails' forgery protection accepts.
// Global 15s timeout prevents hung requests from blocking auto-save timers.
$.ajaxSetup({
  timeout: 15000,
  beforeSend: function(xhr, settings) {
    if (!/^(GET|HEAD|OPTIONS|TRACE)$/i.test(settings.type)) {
      var token = $('meta[name="csrf-token"]').attr('content');
      if (token) xhr.setRequestHeader('X-CSRF-Token', token);
    }
  }
});

window.global = {
  _searchTimer: null,

  ready: function() {
    // All handlers delegate from <body> so they survive Turbo Drive body replacements
    // without needing to be re-bound on each visit.
    $('body').on('click', '.xw-nav__search-icon', global.submit_closest_form);
    $('body').on('keyup', '#query', global.live_search);
    $('body').on('click', '#dropdown-login', function(e) {
      e.stopPropagation();
    });
  },

  submit_closest_form: function() {
    $(this).closest('form').submit();
  },

  live_search: function() {
    var query = $('#query').val();
    if (query.length < 3) {
      $('#live-results').hide();
      if (global._searchTimer) clearTimeout(global._searchTimer);
      return;
    }
    // Debounce: wait 300ms after last keystroke before firing AJAX
    if (global._searchTimer) clearTimeout(global._searchTimer);
    global._searchTimer = setTimeout(function() {
      $.ajax({
        dataType: 'json',
        type: 'GET',
        url: "/live_search",
        data: { query: query },
        success: function(data) {
          if (data.result_count > 0) {
            $('#live-results').empty().append(data.html);
            $('#live-results').show();
          } else {
            $('#live-results').hide().empty();
          }
        },
        error: function() { $('#live-results').hide(); }
      });
    }, 300);
  }
};

// Show the Turbo progress bar after 200ms (default 500ms) so users see feedback
// faster, especially during Heroku dyno wake-up.
if (window.Turbo && Turbo.config && Turbo.config.drive) {
  Turbo.config.drive.progressBarDelay = 200;
}

// Animate comments/replies on Turbo Stream insert/remove.
// Intercepts turbo:before-stream-render to:
//   - Insertion (append/after): add .xw-animate-in to template content before DOM insertion
//   - Removal: apply .xw-animate-out fade, delay Turbo's remove until animation completes
(function() {
  var reducedMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;

  document.addEventListener('turbo:before-stream-render', function(event) {
    var action = event.target.getAttribute('action');
    var defaultRender = event.detail.render;

    event.detail.render = function(streamElement) {
      // Insertion: tag new comments/replies with entrance animation class
      if (!reducedMotion && (action === 'append' || action === 'after')) {
        var tpl = streamElement.querySelector('template');
        if (tpl && tpl.content) {
          var child = tpl.content.firstElementChild;
          while (child) {
            if (child.classList.contains('xw-comment') || child.classList.contains('xw-reply')) {
              child.classList.add('xw-animate-in');
            }
            child = child.nextElementSibling;
          }
        }
      }

      // Removal: fade out comments, replies, and dividers before removing
      if (!reducedMotion && action === 'remove') {
        var targetId = streamElement.getAttribute('target');
        var el = targetId && document.getElementById(targetId);
        if (el && (el.classList.contains('xw-comment') || el.classList.contains('xw-reply') || el.classList.contains('xw-comment__divider'))) {
          el.classList.add('xw-animate-out');
          el.addEventListener('animationend', function() {
            defaultRender(streamElement);
          }, { once: true });
          // Safety: ensure removal if animationend doesn't fire (e.g., detached element)
          setTimeout(function() {
            if (document.body.contains(el)) defaultRender(streamElement);
          }, 1000);
          return;
        }
      }

      defaultRender(streamElement);
    };
  });
})();

// Clicked-element loading feedback for Turbo Drive navigations.
// Dims the clicked element and adds a spinner overlay on puzzle cards.
(function() {
  document.addEventListener('turbo:click', function(event) {
    var el = event.target.closest('.xw-puzzle-card, .xw-btn, a');
    if (!el) return;
    el.classList.add('xw-loading');
  });

  // Clean up on page render or failed navigation
  ['turbo:before-render', 'turbo:load'].forEach(function(evt) {
    document.addEventListener(evt, function() {
      document.querySelectorAll('.xw-loading').forEach(function(el) {
        el.classList.remove('xw-loading');
      });
    });
  });
})();

// Use turbo:load instead of $(document).ready() — DOMContentLoaded only fires once,
// but turbo:load fires on every Turbo Drive visit. Since all handlers above delegate
// from <body> (which persists across visits), we only need to bind once.
document.addEventListener("turbo:load", function initGlobal() {
  document.removeEventListener("turbo:load", initGlobal); // run once
  global.ready();
});
