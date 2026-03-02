class FavoriteController extends Stimulus.Controller {
  toggle() {
    this.onTarget.classList.toggle('hidden');
    this.offTarget.classList.toggle('hidden');
  }
}
FavoriteController.targets = ['on', 'off'];
window.StimulusApp.register('favorite', FavoriteController);
