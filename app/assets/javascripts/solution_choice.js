function solution_choice_ready() {
  // Click anywhere on a solution row (except delete) to navigate to that solution
  $("tbody").on("click", "tr td:not(.trash-td)", function(e) {
    e.preventDefault();
    var $row = $(this).parent();
    var link = $row.data("link");
    if (link) {
      $row.addClass('xw-loading');
      Turbo.visit(link);
    }
  });
}

// Use turbo:load so handlers run after Turbo Drive replaces the body.
// Remove+re-add to prevent duplicate listeners if the script re-executes.
if (window._solutionChoiceTurboLoadHandler) document.removeEventListener("turbo:load", window._solutionChoiceTurboLoadHandler);
window._solutionChoiceTurboLoadHandler = function() {
  if (!$('.xw-solutions-table').length) return; // not on the solution choice page
  solution_choice_ready();
};
document.addEventListener("turbo:load", window._solutionChoiceTurboLoadHandler);
// Body script may execute after turbo:load has already fired — run immediately if DOM ready.
if (document.readyState !== 'loading' && $('.xw-solutions-table').length) {
  solution_choice_ready();
}
