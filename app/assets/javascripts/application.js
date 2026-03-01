//
// require jquery
//= require foundation5/jquery
//= require turbo_sprockets
// turbo_sprockets.js: Sprockets-compatible build of turbo.min.js (ES module export stripped).
// jquery_ujs removed — Turbo now handles all form/link interception.
//
// require turbolinks (removed — replaced by turbo above)
// underscore-min removed — usages replaced with Array.prototype.includes / Object.keys().forEach()
// require foundation5/foundation.min (removed — Phase 4 replaces Foundation JS with Stimulus + native HTML)
// require foundation5/modernizr (removed — not needed for modern browsers)
//
//= require stimulus_sprockets
// stimulus_sprockets.js: Sprockets-compatible build of stimulus.min.js (ES module export replaced
// with window.Stimulus = {Application, Controller}). Controllers live in app/assets/javascripts/controllers/.
//= require_tree ./controllers
//
//= require moment.min
//= require sugar.min
//= require global
//