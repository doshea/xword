(function() {
  window.welcome = {
    ready: function() {
      $('#signup1').on('click', welcome.slide_left);
      return $('#signup2').on('click', welcome.slide_right);
    },
    slide_left: function(e) {
      e.preventDefault();
      return $('.slider').animate({
        'marginLeft': "-=23.3em"
      });
    },
    slide_right: function(e) {
      e.preventDefault();
      return $('.slider').animate({
        'marginLeft': "+=23.3em"
      });
    }
  };

  $(document).ready(welcome.ready);

}).call(this);
