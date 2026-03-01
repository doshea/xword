//
// require jquery
//= require foundation5/jquery
//= require turbo_sprockets
// jquery_ujs removed — Turbo now handles all form/link interception (replaces jquery_ujs remote: true)
// Note: turbo_sprockets.js is a Sprockets-compatible copy of turbo.min.js with the ES module `export`
// statement stripped. turbo-rails 2.x ships only ES module builds; the `export` at the top level of a
// classic script causes a SyntaxError that prevents the entire bundle from executing.
//
// require turbolinks (removed — replaced by turbo above)
// underscore-min removed — the two usages (_. contains, _.each) were replaced with
// Array.prototype.includes and Object.keys().forEach() respectively.
//
// require foundation5/foundation.min
//
// require foundation5/modernizr
//
//= require moment.min
//= require sugar.min
//= require global
//