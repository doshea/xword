// Toggle between "By Day" and "Calendar" views on the NYT page.
// Two button targets, two panel targets. Mirrors tabs_controller pattern
// but uses different class names to avoid conflicts with nested tabs.
class NytViewController extends Stimulus.Controller {
  show(event) {
    event.preventDefault();
    var clickedBtn = event.currentTarget;

    this.btnTargets.forEach(function(btn) {
      btn.classList.toggle('xw-view-btn--active', btn === clickedBtn);
    });

    var panels = this.panelTargets;
    var clickedIndex = this.btnTargets.indexOf(clickedBtn);
    panels.forEach(function(panel, i) {
      panel.classList.toggle('nyt-view-panel--active', i === clickedIndex);
    });
  }
}
NytViewController.targets = ['btn', 'panel'];
window.StimulusApp.register('nyt-view', NytViewController);
