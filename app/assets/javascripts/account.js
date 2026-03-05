// Event delegation: handles .slide-close buttons added dynamically by Turbo Streams.
// Bound once on document — works for both initial and injected markup.
$(document).on('click', '.slide-close', function(e) {
  e.preventDefault();
  $(this).parent().slideUp();
});
