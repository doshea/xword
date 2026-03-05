// Notification dropdown: lazy-fetch on first open, mark-all-read, outside-click close.
// Target: panel (the .xw-notification-dropdown element)
//
// Usage:
//   .xw-nav__item{ data: { controller: 'notification-dropdown' } }
//     %button{ data: { action: 'notification-dropdown#toggle' } }
//     .xw-notification-dropdown{ data: { 'notification-dropdown-target': 'panel' } }

class NotificationDropdownController extends Stimulus.Controller {
  connect() {
    this.loaded = false;
    var self = this;
    this._onOutsideClick = function(e) {
      if (!self.element.contains(e.target)) self.close();
    };
    document.addEventListener('click', this._onOutsideClick);
  }

  disconnect() {
    document.removeEventListener('click', this._onOutsideClick);
  }

  toggle(event) {
    event.stopPropagation();
    var isOpen = this.panelTarget.classList.toggle('is-open');
    var btn = this.element.querySelector('[aria-expanded]');
    if (btn) btn.setAttribute('aria-expanded', String(isOpen));
    if (isOpen && !this.loaded) {
      this.fetchNotifications();
    }
  }

  close() {
    this.panelTarget.classList.remove('is-open');
    var btn = this.element.querySelector('[aria-expanded]');
    if (btn) btn.setAttribute('aria-expanded', 'false');
  }

  fetchNotifications() {
    var panel = this.panelTarget;
    var self = this;
    fetch('/notifications/dropdown', {
      headers: { 'Accept': 'text/html' }
    })
    .then(function(response) { return response.text(); })
    .then(function(html) {
      panel.innerHTML = html;
      self.loaded = true;
    })
    .catch(function() {
      panel.innerHTML = '<p class="xw-notification-dropdown__empty">Could not load notifications.</p>';
    });
  }

  // Called by "Mark all read" button inside the fetched dropdown partial
  markAllRead(event) {
    event.preventDefault();
    var btn = event.currentTarget;
    btn.disabled = true;

    var csrfMeta = document.querySelector('meta[name="csrf-token"]');
    var token = csrfMeta ? csrfMeta.content : '';

    fetch('/notifications/mark_all_read', {
      method: 'PATCH',
      headers: {
        'Accept': 'application/json',
        'X-CSRF-Token': token
      }
    })
    .then(function() {
      // Remove unread styling from all notification rows
      var unreads = document.querySelectorAll('.xw-notification--unread');
      unreads.forEach(function(el) { el.classList.remove('xw-notification--unread'); });

      // Clear the nav badge
      var navMail = document.getElementById('nav-mail');
      if (navMail) navMail.classList.remove('unread');
      var badge = document.querySelector('#notification-badge .xw-badge');
      if (badge) badge.remove();

      // Hide the "Mark all read" button itself
      btn.style.display = 'none';
    });
  }

  // Public: re-fetch dropdown content. Called by notifications_channel.js
  // when ActionCable pushes a new notification.
  refresh() {
    if (!this.loaded) return;
    var panel = this.panelTarget;
    fetch('/notifications/dropdown', {
      headers: { 'Accept': 'text/html' }
    })
    .then(function(response) { return response.text(); })
    .then(function(html) { panel.innerHTML = html; });
  }
}

NotificationDropdownController.targets = ['panel'];
window.StimulusApp.register('notification-dropdown', NotificationDropdownController);
