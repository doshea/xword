class AlertController extends Stimulus.Controller {
  dismiss() {
    this.element.remove();
  }
}
window.StimulusApp.register('alert', AlertController);
