class TabsController extends Stimulus.Controller {
  connect() {
    // Ensure first tab is marked active if none are (defensive against missing HTML class)
    if (!this.tabTargets.find(t => t.classList.contains('xw-tab--active'))) {
      if (this.tabTargets[0]) this.tabTargets[0].classList.add('xw-tab--active');
      if (this.panelTargets[0]) this.panelTargets[0].classList.add('xw-tab-panel--active');
    }
  }

  show(event) {
    event.preventDefault();
    const panelId = event.currentTarget.getAttribute('href').slice(1);
    const activeTab = event.currentTarget;

    this.tabTargets.forEach(tab => {
      tab.classList.toggle('xw-tab--active', tab === activeTab);
    });
    this.panelTargets.forEach(panel => {
      panel.classList.toggle('xw-tab-panel--active', panel.id === panelId);
    });
  }
}
TabsController.targets = ['tab', 'panel'];
window.StimulusApp.register('tabs', TabsController);
