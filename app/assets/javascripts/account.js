window.account = {
  ready: function() {
    $('.slide-close').on('click', function(e) {
      e.preventDefault();
      $(this).parent().slideUp();
    });
  }
};

// Use turbo:load so account.ready() runs after Turbo Drive replaces the body.
// Remove+re-add to prevent duplicate listeners if the script re-executes.
if (window._accountTurboLoadHandler) document.removeEventListener("turbo:load", window._accountTurboLoadHandler);
window._accountTurboLoadHandler = function() {
  if (!$('.slide-close').length) return; // not on an account page
  account.ready();
};
document.addEventListener("turbo:load", window._accountTurboLoadHandler);
