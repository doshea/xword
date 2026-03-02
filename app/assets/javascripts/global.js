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
      var settings = {
        dataType: 'script',
        type: 'GET',
        url: "/live_search",
        data: { query: query }
      };
      settings.error = function() { $('#live-results').hide(); };
      $.ajax(settings);
    }, 300);
  }
};

// Show the Turbo progress bar after 200ms (default 500ms) so users see feedback
// faster, especially during Heroku dyno wake-up.
if (window.Turbo && Turbo.config && Turbo.config.drive) {
  Turbo.config.drive.progressBarDelay = 200;
}

// Use turbo:load instead of $(document).ready() — DOMContentLoaded only fires once,
// but turbo:load fires on every Turbo Drive visit. Since all handlers above delegate
// from <body> (which persists across visits), we only need to bind once.
document.addEventListener("turbo:load", function initGlobal() {
  document.removeEventListener("turbo:load", initGlobal); // run once
  global.ready();
});
