// Stimulus application — starts the global Application instance.
// window.Stimulus is set by stimulus_sprockets.js (loaded before this via require_tree).
// Individual controllers register themselves at the bottom of their own files:
//   window.StimulusApp.register("controller-name", ControllerClass)
//
// Usage in HAML:
//   %div{ data: { controller: "nav" } }
//     %button{ data: { action: "nav#toggle" } }

window.StimulusApp = Stimulus.Application.start();
