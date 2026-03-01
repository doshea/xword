// Nav controller: mobile hamburger toggle + click-outside-to-close.
// Targets: hamburger (the <button>), menu (the collapsible nav panel).
// Usage:
//   %nav{ data: { controller: 'nav' } }
//     %button{ data: { action: 'nav#toggle', nav_target: 'hamburger' } }
//     .xw-nav__menu{ data: { nav_target: 'menu' } }

class NavController extends Stimulus.Controller {
  toggle() {
    var open = this.menuTarget.classList.toggle('is-open');
    this.hamburgerTarget.setAttribute('aria-expanded', String(open));
    this.hamburgerTarget.classList.toggle('is-open', open);
  }

  close() {
    this.menuTarget.classList.remove('is-open');
    this.hamburgerTarget.setAttribute('aria-expanded', 'false');
    this.hamburgerTarget.classList.remove('is-open');
  }

  connect() {
    var self = this;
    this._onOutsideClick = function(e) {
      if (!self.element.contains(e.target)) self.close();
    };
    document.addEventListener('click', this._onOutsideClick);
  }

  disconnect() {
    document.removeEventListener('click', this._onOutsideClick);
  }
}

NavController.targets = ['hamburger', 'menu'];
window.StimulusApp.register('nav', NavController);
