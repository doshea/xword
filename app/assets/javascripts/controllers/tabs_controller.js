class TabsController extends Stimulus.Controller {
  connect() {
    // Ensure first tab is marked active if none are (defensive against missing HTML class)
    if (!this.tabTargets.find(t => t.classList.contains('xw-tab--active'))) {
      if (this.tabTargets[0]) this.tabTargets[0].classList.add('xw-tab--active');
      if (this.panelTargets[0]) this.panelTargets[0].classList.add('xw-tab-panel--active');
    }
    // Sync aria-selected with active state on connect
    this.tabTargets.forEach(function(tab) {
      tab.setAttribute('aria-selected', tab.classList.contains('xw-tab--active') ? 'true' : 'false');
    });
  }

  show(event) {
    event.preventDefault();
    const el = event.currentTarget;
    const panelId = el.getAttribute('aria-controls') || (el.getAttribute('href') || '').slice(1);
    const activeTab = event.currentTarget;

    this.tabTargets.forEach(tab => {
      var isActive = tab === activeTab;
      tab.classList.toggle('xw-tab--active', isActive);
      tab.setAttribute('aria-selected', isActive ? 'true' : 'false');
    });
    this.panelTargets.forEach(panel => {
      panel.classList.toggle('xw-tab-panel--active', panel.id === panelId);
    });

    // Lazy-load tab content if panel has data-lazy-src and hasn't been fetched yet
    var activePanel = this.panelTargets.find(function(p) { return p.id === panelId; });
    if (activePanel && activePanel.dataset.lazySrc && !activePanel.dataset.loaded) {
      fetch(activePanel.dataset.lazySrc, {
        headers: { 'X-Requested-With': 'XMLHttpRequest' }
      })
        .then(function(r) { return r.text(); })
        .then(function(html) {
          activePanel.innerHTML = html;
          activePanel.dataset.loaded = 'true';
        })
        .catch(function() {
          activePanel.innerHTML = '<p class="xw-empty-state">Failed to load. Please refresh.</p>';
        });
    }
  }
}
TabsController.targets = ['tab', 'panel'];
window.StimulusApp.register('tabs', TabsController);
