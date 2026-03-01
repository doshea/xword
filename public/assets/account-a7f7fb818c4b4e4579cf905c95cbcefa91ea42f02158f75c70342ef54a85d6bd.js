window.account = {
  ready: function() {
    $('.slide-close').on('click', function(e) {
      e.preventDefault();
      $(this).parent().slideUp();
    });
  }
};

$(document).ready(account.ready);
