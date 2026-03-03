class CopyLinkController extends Stimulus.Controller {
  copy() {
    var input = this.inputTarget;
    input.select();
    navigator.clipboard.writeText(input.value);
    var btn = this.buttonTarget;
    btn.dataset.xwTooltip = 'Copied!';
    btn.classList.add('xw-tooltip--flash');
    setTimeout(function() {
      btn.dataset.xwTooltip = 'Copy link';
      btn.classList.remove('xw-tooltip--flash');
    }, 1500);
  }
}
CopyLinkController.targets = ['input', 'button'];
window.StimulusApp.register('copy-link', CopyLinkController);
