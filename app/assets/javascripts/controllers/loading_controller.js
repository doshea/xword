// Disables submit button and shows a spinner during Turbo form submissions.
// Usage:
//   %form{ data: { controller: 'loading' } }
//     = submit_tag 'Send', data: { loading_target: 'button' }
class LoadingController extends Stimulus.Controller {
  connect() {
    this._onEnd = this._restore.bind(this);
    this.element.addEventListener('turbo:submit-end', this._onEnd);
  }

  disconnect() {
    this.element.removeEventListener('turbo:submit-end', this._onEnd);
  }

  submit() {
    if (!this.hasButtonTarget) return;
    this._originalText = this.buttonTarget.value || this.buttonTarget.textContent;
    this.buttonTarget.disabled = true;
    this.buttonTarget.value = 'Loading\u2026';
  }

  _restore() {
    if (!this.hasButtonTarget) return;
    this.buttonTarget.disabled = false;
    if (this._originalText) {
      this.buttonTarget.value = this._originalText;
    }
  }
}
LoadingController.targets = ['button'];
window.StimulusApp.register('loading', LoadingController);
