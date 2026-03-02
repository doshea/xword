window.global = {
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
    } else {
      var settings = {
        dataType: 'script',
        type: 'GET',
        url: "/live_search",
        data: { query: query }
      };
      $.ajax(settings);
    }
  }
};

// Use turbo:load instead of $(document).ready() — DOMContentLoaded only fires once,
// but turbo:load fires on every Turbo Drive visit. Since all handlers above delegate
// from <body> (which persists across visits), we only need to bind once.
document.addEventListener("turbo:load", function initGlobal() {
  document.removeEventListener("turbo:load", initGlobal); // run once
  global.ready();
});
