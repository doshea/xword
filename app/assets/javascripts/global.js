window.global = {
  ready: function() {
    $('body').on('click', '.fi-magnifying-glass', global.submit_closest_form);
    $('#top-search').on('keyup', '#query', global.live_search);
    $('#dropdown-login').on('click', function(e) {
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

$(document).ready(global.ready);
