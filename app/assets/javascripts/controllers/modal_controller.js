class ModalController extends Stimulus.Controller {
  open() {
    this.element.showModal();
  }

  close() {
    this.element.close();
  }

  // Close when user clicks the backdrop (outside the dialog box)
  clickOutside(event) {
    if (event.target === this.element) {
      this.element.close();
    }
  }
}
window.StimulusApp.register('modal', ModalController);
