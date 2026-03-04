// Chalkboard controller: slide between signup and login panels on the welcome page.
// Usage:
//   .xw-chalkboard{ data: { controller: 'chalkboard' } }
//     .xw-chalkboard__slider
//       .xw-chalkboard__panel--signup
//         %button{ data: { action: 'chalkboard#showLogin' } }
//       .xw-chalkboard__panel--login
//         %button{ data: { action: 'chalkboard#showSignup' } }

class ChalkboardController extends Stimulus.Controller {
  showLogin(event) {
    event.preventDefault();
    this.element.classList.add('xw-chalkboard--login-active');

    // Focus first login input after CSS transition completes
    var loginInput = this.element.querySelector(
      '.xw-chalkboard__panel--login .xw-chalkboard__input'
    );
    if (loginInput) {
      setTimeout(function() { loginInput.focus(); }, 350);
    }
  }

  showSignup(event) {
    event.preventDefault();
    this.element.classList.remove('xw-chalkboard--login-active');

    // Focus first signup input after CSS transition completes
    var signupInput = this.element.querySelector(
      '.xw-chalkboard__panel--signup .xw-chalkboard__input'
    );
    if (signupInput) {
      setTimeout(function() { signupInput.focus(); }, 350);
    }
  }
}

window.StimulusApp.register('chalkboard', ChalkboardController);
