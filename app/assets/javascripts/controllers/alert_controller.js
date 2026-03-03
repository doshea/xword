class AlertController extends Stimulus.Controller {
  connect() {
    // Auto-dismiss Turbo Stream-injected alerts after 5 seconds.
    // Full-page flash alerts also get this, which is fine — they only show once.
    this.timeout = setTimeout(this.dismiss.bind(this), 5000);
  }

  disconnect() {
    if (this.timeout) clearTimeout(this.timeout);
  }

  dismiss() {
    this.element.remove();
  }
}
window.StimulusApp.register('alert', AlertController);
