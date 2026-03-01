// Dropdown controller: toggle a menu open/closed, close on outside click.
// Target: menu (the .xw-nav__dropdown panel element).
// Usage:
//   .xw-nav__item{ data: { controller: 'dropdown' } }
//     %button{ data: { action: 'dropdown#toggle' } }
//     .xw-nav__dropdown{ data: { dropdown_target: 'menu' } }

class DropdownController extends Stimulus.Controller {
  toggle() {
    this.menuTarget.classList.toggle('is-open');
  }

  close() {
    this.menuTarget.classList.remove('is-open');
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

DropdownController.targets = ['menu'];
window.StimulusApp.register('dropdown', DropdownController);
