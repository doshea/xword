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
    var btn = this.buttonTarget;
    this._originalHTML = btn.innerHTML;
    this._originalValue = btn.value;
    btn.disabled = true;
    // For <input type="submit"> (has value), swap value text
    if (btn.tagName === 'INPUT') {
      btn.value = 'Loading\u2026';
    }
    // For <button>, inject spinner into innerHTML
    else {
      btn.innerHTML = '<span class="xw-spinner"></span> Loading\u2026';
    }
  }

  _restore() {
    if (!this.hasButtonTarget) return;
    var btn = this.buttonTarget;
    btn.disabled = false;
    if (btn.tagName === 'INPUT' && this._originalValue) {
      btn.value = this._originalValue;
    } else if (this._originalHTML) {
      btn.innerHTML = this._originalHTML;
    }
  }
}
LoadingController.targets = ['button'];
window.StimulusApp.register('loading', LoadingController);
